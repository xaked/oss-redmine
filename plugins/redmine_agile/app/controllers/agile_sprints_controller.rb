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

class AgileSprintsController < ApplicationController
  helper :agile_sprints
  include AgileSprintsHelper

  before_action :find_optional_project, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_agile_sprint, only: [:edit, :update, :destroy]

  def new
    @agile_sprint = @project.agile_sprints.build(initial_agile_sprint_params)
  end

  def create
    @agile_sprint = @project.agile_sprints.build
    @agile_sprint.safe_attributes = params[:agile_sprint]
    if @agile_sprint.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html { redirect_to_settings_in_projects }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.api  { render_validation_errors(@agile_sprint) }
      end
    end
  end

  def edit
  end

  def update
    @agile_sprint.safe_attributes = params[:agile_sprint]
    if @agile_sprint.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_to_settings_in_projects }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.api  { render_validation_errors(@agile_sprint) }
      end
    end
  end

  def destroy
    @agile_sprint.destroy
    respond_to do |format|
      format.html { redirect_to_settings_in_projects }
      format.api { render_api_ok }
    end
  end

  private

  def initial_agile_sprint_params
    last_sprint = @project.agile_sprints.last
    {
      name: last_sprint ? last_sprint.name.gsub(/(\d+)/) { $&.to_i + 1 } : '',
      start_date: workday_for(Date.today)
    }
  end

  def workday_for(date)
    return date + 1 if date.instance_eval { sunday? }
    return date + 2 if date.instance_eval { saturday? }
    date
  end

  def find_agile_sprint
    @agile_sprint = @project.agile_sprints.where(id: params[:id]).first
    return render_404 unless @agile_sprint
  end

  def redirect_to_settings_in_projects
    redirect_back_or_default settings_project_path(@project, :tab => 'agile_sprints')
  end
end
