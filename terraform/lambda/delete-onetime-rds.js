const AWS = require("aws-sdk")
const rds = new AWS.RDS()

exports.handler = async function(event, context) {
  const Identifier = event.Identifier

  const snapshot = await rds.deleteDBSnapshot({
    DBSnapshotIdentifier: Identifier
  }).promise()

  console.log(`deleted snapshot: ${snapshot.data}`)

  const instance = await rds.deleteDBInstance({
    DBInstanceIdentifier: Identifier,
    SkipFinalSnapshot: true
  }).promise()

  await rds.waitFor('dBInstanceDeleted', {
    DBInstanceIdentifier: instance.DBInstanceIdentifier
  }).promise()

  console.log(`deleted db instance: ${instance.data}`)

  return context.logStreamName
}
