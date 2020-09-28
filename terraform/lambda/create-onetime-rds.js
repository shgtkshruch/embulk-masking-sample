const AWS = require("aws-sdk")
const rds = new AWS.RDS()

exports.handler = async function(event, context) {
  const DBSTmpIdentifier = `embulk-mysql-rds-masking`
  const DBInstanceIdentifier = event.DBInstanceIdentifier

  const snapshotParams = {
    DBSnapshotIdentifier: DBSTmpIdentifier,
    DBInstanceIdentifier
  }
  const dbParams = {
    DBSnapshotIdentifier: DBSTmpIdentifier,
    DBInstanceIdentifier: DBSTmpIdentifier,
    VpcSecurityGroupIds: []
  }

  const snapshot = await rds.createDBSnapshot(snapshotParams).promise()
  console.log(`create snapshot: ${snapshot}`)

  await rds.waitFor('dBSnapshotAvailable', {
    DBSnapshotIdentifier: snapshot.DBSnapshotIdentifier
  }).promise()

  const instance = await rds.restoreDBInstanceFromDBSnapshot(dbParams).promise()

  await rds.waitFor('dBInstanceAvailable', {
    DBInstanceIdentifier: instance.DBInstanceIdentifier
  }).promise()

  console.log(`create db instance: ${instance}`)

  return context.logStreamName
}
