new PublishEndpoint 'Motion.list', (discussionId) ->
  check discussionId, Match.DocumentId

  Motion.documents.find
    'discussion._id': discussionId
  ,
    fields: Motion.PUBLISH_FIELDS()

new PublishEndpoint 'Motion.vote', (motionId) ->
  check motionId, Match.DocumentId

  return @ready() unless @userId

  Vote.documents.find
    'motion._id': motionId
    'author._id': @userId
  ,
    Vote.PUBLISH_FIELDS()
