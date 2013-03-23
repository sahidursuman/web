# Copyright 2012 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# This observer on the {Occurrence} model:
#
# * sends an email when a Bug is critical, and
# * sets the `any_occurrence_crashed` field on the associated Bug.

class OccurrenceObserver < ActiveRecord::Observer
  # @private
  def after_save(occurrence)
    occurrence.bug.update_attribute :any_occurrence_crashed, true if occurrence.crashed?
  end

  # @private
  def after_commit_on_create(occurrence)
    # send emails
    BackgroundRunner.run OccurrenceNotificationMailer, occurrence.id

    # notify pagerduty
    BackgroundRunner.run PagerDutyNotifier, occurrence.id
  end
end
