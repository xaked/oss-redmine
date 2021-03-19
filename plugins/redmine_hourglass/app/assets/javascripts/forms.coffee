initIssueAutoCompletion = ->
  $issueField = $(@)
  $projectField = $issueField.closest('form').find('[name*=v\\[project_id\\]]')
  $issueField.autocomplete
    source: (request, response) ->
      $.ajax
        url: hourglassRoutes.hourglass_completion_issues(project_id: $projectField.val()),
        dataType: 'json',
        data: request
        success: response
    minLength: 1,
    autoFocus: true,
    response: (event, ui) ->
      $(event.target).next().val('')
    select: (event, ui) ->
      event.preventDefault()
      $issueField
      .val(ui.item.label)
      .next().val(ui.item.issue_id)
      .trigger('change')
      $projectField.val(ui.item.project_id).trigger('changefromissue') if $projectField.val() isnt ui.item.project_id
    focus: (event, ui) ->
      event.preventDefault()

updateActivityField = ($activityField, $projectField) ->
  $selected_activity = $activityField.find("option:selected")
  $.ajax
    url: hourglassRoutes.hourglass_completion_activities()
    data:
      project_id: $projectField.val()
    success: (activities) ->
      $activityField.find('option[value!=""]').remove()
      for {id, name, isDefault} in activities
        do ->
          $activityField.append $('<option/>', value: id).text(name)
          if $projectField.val() is ''
            $activityField.val null
            $activityField.trigger('change')
          else if $selected_activity.text() is name or ($selected_activity.val() is '' and isDefault)
            $activityField.val id
            $activityField.trigger('change')
      hourglass.FormValidator.validateField $activityField

updateUserField = ($userField, $projectField) ->
  selected_user = $userField.find("option:selected").text()
  $.ajax
    url: hourglassRoutes.hourglass_completion_users()
    data:
      project_id: $projectField.val()
    success: (users) ->
      $userField.find('option[value!=""]').remove()
      for {id, name} in users
        do ->
          $userField.append $('<option/>', value: id).text(name)
          $userField.val id if selected_user is name
      hourglass.FormValidator.validateField $userField

updateDurationField = ($startField, $stopField) ->
  start = moment $startField.val(), moment.ISO_8601
  stop = moment $stopField.val(), moment.ISO_8601
  $startField.closest('form').find('.js-duration').val hourglass.Utils.formatDuration moment.duration stop.diff(start)

updateLink = ($field) ->
  $link = $field.closest('.form-field').find('label + a')
  if $link.length
    $link.toggleClass 'hidden', $field.val() is ''
    $link.attr('href', $link.attr('href').replace(/\/([^/]*)$/, "/#{$field.val()}"))

formFieldChanged = (event) ->
  $target = $(event.target)
  $target = $target.next() if $target.hasClass('js-linked-with-hidden')
  hourglass.FormValidator.validateField $target
  $target.trigger 'formfieldchanged'

startFieldChanged = (event) ->
  $startField = $(event.target)
  return if $startField.hasClass('invalid')
  $stopField = $startField.closest('form').find('[name*=stop]')
  if $stopField.length > 0
    hourglass.FormValidator.validateField $stopField
    updateDurationField $startField, $stopField

stopFieldChanged = (event) ->
  $stopField = $(event.target)
  return if $stopField.hasClass('invalid')
  $startField = $stopField.closest('form').find('[name*=start]')
  hourglass.FormValidator.validateField $startField
  updateDurationField $startField, $stopField

durationFieldChanged = (event) ->
  $durationField = $(event.target)
  return if $durationField.hasClass('invalid')
  $startField = $durationField.closest('form').find('[name*=start]')
  $stopField = $durationField.closest('form').find('[name*=stop]')
  duration = hourglass.Utils.parseDuration $durationField.val()
  hourglass.timeField.setValue $stopField, moment($startField.val()).add(duration)
  hourglass.FormValidator.validateField $stopField

projectFieldChanged = (event) ->
  $projectField = $(@)
  $form = $projectField.closest('form')
  $issueTextField = $form.find('.js-issue-autocompletion')
  $activityField = $form.find('[name*=v\\[activity_id\\]]')
  $userField = $form.find('[name*=v\\[user_id\\]]')

  round = $projectField.find(':selected').data('round-default')
  $form.find('[type=checkbox][name*=round]').prop('checked', round) unless round is null
  sumsOnly = $projectField.find(':selected').data('round-sums-only')
  roundingDisabled = if sumsOnly is undefined then $projectField.val() is '' else sumsOnly
  $form.find('[type=checkbox][name*=round]').prop('disabled', roundingDisabled)
    .closest('.form-field').toggleClass('hidden', roundingDisabled)

  $issueTextField.val('').trigger('change') unless $issueTextField.val() is '' or event.type is 'changefromissue'
  hourglass.FormValidator.validateField $projectField if event.type is 'changefromissue'
  updateActivityField $activityField, $projectField
  updateUserField $userField, $projectField if $userField.length > 0
  updateLink $projectField

issueFieldChanged = ->
  $issueTextField = $(@)
  $issueField = $issueTextField.next()
  $issueField.val('') if $issueTextField.val() is ''
  updateLink $issueField

split = (timeLogId, mSplitAt, insertNewBefore, round) ->
  $.ajax
    url: hourglassRoutes.split_hourglass_time_log timeLogId
    method: 'post'
    data:
      split_at: mSplitAt.toJSON()
      insert_new_before: insertNewBefore
      round: round

submit_without_split_checking = ($form) ->
  $form
  .removeClass('js-check-splitting')
  .submit()

addSplittingSuccessfulHandler = ($form, startJqXhr, stopJqXhr) ->
  if startJqXhr
    startJqXhr.done ->
      submit_without_split_checking $form
  else if stopJqXhr
    stopJqXhr.done ->
      submit_without_split_checking $form

addSplittingFailedHandler = (startJqXhr, stopJqXhr) ->
  if stopJqXhr
    stopJqXhr.fail ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message
  if startJqXhr
    startJqXhr.fail ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message

checkSplitting = ->
  $form = $(@)
  timeLogId = $form.data('timeLogId')
  $startField = $form.find('[name*=start]')
  $stopField = $form.find('[name*=stop]')
  mStart = moment $startField.val(), moment.ISO_8601
  mStop = moment $stopField.val(), moment.ISO_8601
  round = $form.find('[type=checkbox][name*=round]').prop('checked')
  stopJqXhr = if mStop.isBefore $stopField.data('mLimit')
    split timeLogId, mStop, false, round
  startJqXhr = if mStart.isAfter $startField.data('mLimit')
    if stopJqXhr
      stopJqXhr.then ->
        split timeLogId, mStart, true, round
    else
      split timeLogId, mStart, true, round

  addSplittingSuccessfulHandler $form, startJqXhr, stopJqXhr
  addSplittingFailedHandler startJqXhr, stopJqXhr

  return not (startJqXhr or stopJqXhr)

$ ->
  $(document)
  .on 'focus', '.js-issue-autocompletion:not(.ui-autocomplete-input)', initIssueAutoCompletion
  .on 'change', '.js-validate-form', formFieldChanged
  .on 'change changefromissue', '[name*=project_id]', projectFieldChanged
  .on 'change changefromissue', '#cb_project_id', projectFieldChanged
  .on 'change', '.js-issue-autocompletion', issueFieldChanged
  .on 'formfieldchanged', '[name*=start]', startFieldChanged
  .on 'formfieldchanged', '[name*=stop]', stopFieldChanged
  .on 'formfieldchanged', '.js-duration', durationFieldChanged
  .on 'submit ajax:before', '.js-validate-form', (event) ->
    isFormValid = hourglass.FormValidator.validateForm $(@)
    unless isFormValid
      event.preventDefault()
      event.stopPropagation()
    return isFormValid
  .on 'ajax:before', '.js-check-splitting', checkSplitting
  $('.js-issue-autocompletion:focus:not(.ui-autocomplete-input)').each(initIssueAutoCompletion)