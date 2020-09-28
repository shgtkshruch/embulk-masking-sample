const AWS = require("aws-sdk")
const rds = new AWS.RDS()

exports.handler = async function(event, context) {
  const DBSnapshotIdentifier = event.DBSnapshotIdentifier
  const DBInstanceIdentifier = event.DBInstanceIdentifier

  if (DBSnapshotIdentifier) {
    const snapshot = await rds.deleteDBSnapshot({ DBSnapshotIdentifier }).promise()
    console.log(`deleted snapshot: ${snapshot.data}`)
  }

  if (DBInstanceIdentifier) {
    const instance = await rds.deleteDBInstance({
      DBInstanceIdentifier,
      SkipFinalSnapshot: true
    }).promise()

    await rds.waitFor('dBInstanceDeleted', {
      DBInstanceIdentifier: instance.DBInstanceIdentifier
    }).promise()

    console.log(`deleted db instance: ${instance.data}`)
  }

  return context.logStreamName
}
