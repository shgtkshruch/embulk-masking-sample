const AWS = require("aws-sdk")
const rds = new AWS.RDS()

exports.handler = async function(event, context) {
  const Identifier = event.Identifier

  const snapshot = await rds.deleteDBSnapshot({
    DBSnapshotIdentifier: Identifier
  }).promise()
  console.log(`deleted snapshot: ${JSON.stringify(snapshot, null, 2)}`)

  const instance = await rds.deleteDBInstance({
    DBInstanceIdentifier: Identifier,
    SkipFinalSnapshot: true
  }).promise()
  console.log(`start deleting rds instance: ${JSON.stringify(instance, null, 2)}`)

  console.log('wait untile rds deleted')
  await rds.waitFor('dBInstanceDeleted', {
    DBInstanceIdentifier: instance.DBInstanceIdentifier
  }).promise()
  console.log('deleted db instance')

  return context.logStreamName
}
