class Point.ListComponent extends UIComponent
  @register 'Point.ListComponent'

  onCreated: ->
    super

    @currentDiscussionId = new ComputedField =>
      FlowRouter.getParam '_id'

    @autorun (computation) =>
      @subscribe 'Point.list', @currentDiscussionId()

  inFavorPoints: ->
    Point.documents.find
      'discussion._id': @currentDiscussionId()
      category: Point.CATEGORY.IN_FAVOR

  againstPoints: ->
    Point.documents.find
      'discussion._id': @currentDiscussionId()
      category: Point.CATEGORY.AGAINST

  otherPoints: ->
    Point.documents.find
      'discussion._id': @currentDiscussionId()
      category: Point.CATEGORY.OTHER

class Point.ListItemComponent extends share.UpvotableItemComponent
  @register 'Point.ListItemComponent'

  methodPrefix: ->
    'Point'