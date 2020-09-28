const AWS = require("aws-sdk")
const rds = new AWS.RDS()

exports.handler = async function(event, context) {
  const timestamp = Date.now()
  const DBSTmpIdentifier = `embulk-mysql-rds-masking-${timestamp}`
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
  console.log(`create snapshot: ${JSON.stringify(snapshot, null, 2)}`)

  console.log('wait untile snapshot available')
  await rds.waitFor('dBSnapshotAvailable', {
    DBSnapshotIdentifier: snapshot.DBSnapshotIdentifier
  }).promise()
  console.log('snapshot available!')

  const instance = await rds.restoreDBInstanceFromDBSnapshot(dbParams).promise()
  console.log(`start creating rds instance: ${JSON.stringify(instance, null, 2)}`)

  console.log('wait untile rds available')
  await rds.waitFor('dBInstanceAvailable', {
    DBInstanceIdentifier: instance.DBInstanceIdentifier
  }).promise()
  console.log('rds available!')

  return {
    Identifier: DBSTmpIdentifier
  }
}
