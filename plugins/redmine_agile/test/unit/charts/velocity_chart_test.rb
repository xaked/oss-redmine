# encoding: utf-8
#
# This file is a part of Redmin Agile (redmine_agile) plugin,
# Agile board plugin for redmine
#
# Copyright (C) 2011-2021 RedmineUP
# http://www.redmineup.com/
#
# redmine_agile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_agile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_agile.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../../test_helper', __FILE__)

class VelocityChartChartTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :enumerations, :issue_statuses, :issue_categories

  def setup
    @user = User.first
    @tracker = Tracker.first
    @project = Project.first_or_create(name: 'VelocityChartChartTest', identifier: 'velocitycharttest')
    @project.trackers << @tracker unless @project.trackers.include?(@tracker)
    @new_status = IssueStatus.where(name: 'New').first
    @closed_status = IssueStatus.where(name: 'Closed').first
  end

  def test_returned_data
    chart_data_cases.each do |test_case|
      test_case_issues = test_case[:issues].call
      test_case[:inerval_data].each do |case_interval|
        puts "VelocityChartChartTest case - #{case_interval[:name]}"
        chart_data = RedmineAgile::VelocityChart.data(test_case_issues, case_interval[:options])
        assert_equal case_interval[:result], extract_values(chart_data)
      end
      test_case_issues.destroy_all
    end
  ensure
    @project.issues.destroy_all
    @project.destroy
  end

  private

  def extract_values(chart_data)
    { title: chart_data[:title], datasets: chart_data[:datasets].map { |data| data.slice(:type, :data, :label) } }
  end

  def chart_data_cases
    data_cases = [
      {
        name: 'every month issues',
        issues: Proc.new { Issue.where(id: (1..12).map { |month| create_issue_data(month) }) },
        internals: {
          day: {
            title: 'Velocity',
            dates: { date_from: Date.parse('2018-12-31'), date_to: Date.parse('2019-01-01'), interval_size: 'day' },
            result: [{ type: 'bar', data: [0, 0], label: 'Closed' },
                     { type: 'line', data: [0.0, 0.0], label: 'Closed trendline' },
                     { type: 'bar', data: [0, 2.0], label: 'Created' },
                     { type: 'line', data: [0.0, 2.0], label: 'Created trendline' }]
          },
          month: {
            title: 'Average velocity',
            dates: { date_from: Date.parse('2019-03-01'), date_to: Date.parse('2019-03-31'), interval_size: 'week' },
            result: [{ type: 'bar', data: [1.0, 0, 0, 0, 0], label: 'Closed' },
                     { type: 'line', data: [0.6000000000000001, 0.4, 0.19999999999999996, 0.0], label: 'Closed trendline' },
                     { type: 'bar', data: [1.0, 0, 0, 0, 0], label: 'Created' },
                     { type: 'line', data: [0.6000000000000001, 0.4, 0.19999999999999996, 0.0], label: 'Created trendline' }]
          },
          year: {
            title: 'Average velocity',
            dates: { date_from: Date.parse('2019-01-01'), date_to: Date.parse('2019-12-31'), interval_size: 'month' },
            result: [{ type: 'bar', data: [0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0], label: 'Closed' },
                     { type: 'line', data: [0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461, 0.8461538461538461], label: 'Closed trendline' },
                     { type: 'bar', data: [2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0, 0], label: 'Created' },
                     { type: 'line', data: [1.4835164835164836, 1.39010989010989, 1.2967032967032965, 1.2032967032967032, 1.10989010989011, 1.0164835164835164, 0.923076923076923, 0.8296703296703296, 0.7362637362637362, 0.6428571428571428, 0.5494505494505495, 0.456043956043956, 0.36263736263736246], label: 'Created trendline' }]
          },
          between: {
            title: 'Average velocity',
            dates: { date_from: Date.parse('2019-07-01'), date_to: Date.parse('2019-12-31'), interval_size: 'month' },
            result: [{ type: 'bar', data: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0], label: 'Closed' },
                     { type: 'line', data: [1.1785714285714286, 1.0714285714285716, 0.9642857142857144, 0.8571428571428572, 0.7500000000000001, 0.642857142857143, 0.5357142857142858], label: 'Closed trendline' },
                     { type: 'bar', data: [1.0, 1.0, 1.0, 1.0, 1.0, 0, 0], label: 'Created' },
                     { type: 'line', data: [1.25, 1.0714285714285714, 0.8928571428571429, 0.7142857142857143, 0.5357142857142857, 0.3571428571428572, 0.1785714285714286], label: 'Created trendline' }]
          }
        }
      }
    ]

    test_cases = data_cases.map do |test_case|
      {
        issues: test_case[:issues],
        inerval_data: test_case[:internals].map do |interval_name, interval_data|
                        {
                          name: [test_case[:name], 'interval', interval_name].join(' '),
                          options: { chart_unit: 'issues', interval_size: 'day' }.merge(interval_data[:dates]),
                          result: { title: interval_data[:title], datasets: interval_data[:result] }
                        }
                      end
      }
    end

    test_cases
  end

  def create_issue_data(month)
    mstring = month.to_s.rjust(2, '0')
    pmstring = (month > 1 ? month - 1 : month).to_s.rjust(2, '0')
    issue = Issue.create!(tracker: @tracker,
                          project: @project,
                          author: @user,
                          subject: "Issue ##{month}",
                          status: month != 1 ? @closed_status : @new_status,
                          estimated_hours: month * 2)
    issue.reload
    issue.create_agile_data(story_points: month * 3)
    issue.update(created_on: "2019-#{pmstring}-01 09:00", closed_on: "2019-#{mstring}-01 11:00")
    issue.id
  end
end
