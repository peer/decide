sanitizeAttachmentTree = ($, $element, sanitize) ->
  sanitize.sanitizeTree $, $element, [
    figure:
      attributes:
        class: true
      children:
        img:
          attributes:
            src: true
            width: true
            height: true
        figcaption:
          attributes:
            class: true
          children:
            $text: true
            span:
              attributes:
                class: true
              children:
                $text: true
  ]

# Should sanitize the tag and return its sanitized contents.
sanitizeAttachment = ($, $element, sanitize) ->
  # If it is not attachment, allow only a with href attribute.
  unless $element.attr('data-trix-attachment')
    return sanitize.sanitizeTagAndContents $, $element,
      href: true

  @sanitizeAttributes $, $element,
    'href': true
    'data-trix-attachment': true
    'data-trix-content-type': true
    'data-trix-attributes': true

  # Invalid.
  return unless $element.attr('href')

  href = sanitize.sanitizeHref $, $element.attr('href')
  $element.attr 'href', href

  try
    JSON.parse $element.attr 'data-trix-attachment'
  catch error
    # Invalid.
    return

  try
    JSON.parse $element.attr 'data-trix-attributes' if $element.attr 'data-trix-attributes'
  catch error
    # Invalid.
    return

  sanitizeAttachmentTree $, $element, sanitize

# Should sanitize the tag and return its sanitized contents.
sanitizeAttachmentDisplay = ($, $element, sanitize) ->
  # If it is not attachment, allow only a with href attribute.
  unless $element.attr('data-trix-attachment')
    return sanitize.sanitizeTagAndContents $, $element,
      href: true

  @sanitizeAttributes $, $element,
    'href': true

  # Invalid.
  return unless $element.attr('href')

  href = sanitize.sanitizeHref $, $element.attr('href')
  $element.attr 'href', href

  sanitizeAttachmentTree $, $element, sanitize

class share.BaseDocument extends Document
  @Meta
    abstract: true

  @sanitize: new Sanitize
    div: {}
    br: {}

    strong: {}
    em: {}
    del: {}
    a: sanitizeAttachment
    blockquote: {}
    pre: {}
    ul: {}
    li: {}
    ol: {}

  @sanitizeForDisplay: new Sanitize
    div: {}
    br: {}

    strong: {}
    em: {}
    del: {}
    a: sanitizeAttachmentDisplay
    blockquote: {}
    pre: {}
    ul: {}
    li: {}
    ol: {}

  @extractAttachments: (html) ->
    if Meteor.isServer
      $ = cheerio
    else
      $ = jQuery

    $documentIds = $('[data-trix-attachment]', html).map (i, attachment) =>
      JSON.parse($(attachment).attr('data-trix-attachment')).documentId or null

    # Convert cheerio/jQuery array to a standard array.
    $documentIds.get()
