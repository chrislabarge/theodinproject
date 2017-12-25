class ProjectsController < ApplicationController
  before_action :authenticate_request, except: :index
  before_action :find_lesson
  before_action :find_project, only: %i(update destroy)

  authorize_resource only: %i(update destroy)

  def index
    @projects = all_projects.page(params[:page])
    @course = CourseDecorator.new(@lesson.course)
  end

  def create
    @project = new_project(project_params)
    @project.save
    @projects = latest_projects
  end

  def update
    @project.update(project_params)
    @decorated_project = ProjectDecorator.new(@project)
  end

  def destroy
    @project.destroy
    @project = new_project
    @projects = latest_projects
  end

  private

  def all_projects
    Project.all_submissions(@lesson.id)
  end

  def new_project(parameters = {})
    project = current_user.projects.new(parameters)
    project.lesson_id = @lesson.id
    project
  end

  def latest_projects
    all_projects.order(updated_at: :desc).limit(10)
  end

  def find_project
    @project = Project.find(params[:id])
  end

  def find_lesson
    @lesson = LessonDecorator.new(lesson)
  end

  def lesson
    Lesson.friendly.find(params[:lesson_id])
  end

  def project_params
    params.require(:project).permit(:repo_url, :live_preview)
  end

  def authenticate_request
    return head :unauthorized unless user_signed_in?
  end
end
