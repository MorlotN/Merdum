class GroupsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :index]
  before_action :find_group, only: [:show]
  RESULT_ALL = Hash.new { |hash, key| hash[key] = 0 }

  def index
    @group = Group.all
    @my_groups = current_user.groups
  end

  def show
    # probleme des votes = le hash @result_all qui doit contenir tout les resultats de votes pour chaque event en a qu'un seul
    # RESULT_ALL.nil? ? RESULT_ALL = {} : RESULT_ALL
    cookies[:group] = params[:id]
    @group = Group.find(params[:id])
    @user_groups_members = UserGroup.where(group: @group)
     # do |user_groups_member|
     #      user_groups_member.user
    @members = @user_groups_members.map(&:user)
    @group.event_users.each_with_index do |event_user, index|
      RESULT_ALL["#{event_user.event_id}"] = event_user.score


      # p RESULT_ALL
      # raise
    end
    # raise
    # p RESULT_ALL
    @result_all = RESULT_ALL.max_by{|k,v| v}
    # raise
  end

  def edit
    @group = Group.find(params[:id])
    @nearest = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  end

  def new
    @group = Group.new
    @nearest = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    # @nearest << [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  end

  def create
    cookies[:date_start] = params["group"]["date_event"]
    cookies[:address] = params["group"]["location"]
    params[:date_start] = cookies[:date_start]
    params[:address] = cookies[:address]
    # emails = []
    cookies[:nearest] = params[:nearest]
    params[:nearest] = cookies[:nearest]
    params["invit-email"].nil? ? emails = [] : emails = params["invit-email"]
    emails << params["group"]["email"]
    # emails = emails.map(&:inspect).join(', ').to_a

    @group = Group.new(group_params)
    @group.email = emails
    # cookies[:date_start] = @group.date_event
    # @group.user = current_user
    if @group.save
      @group.users << current_user
      JSON.parse(@group.email).each do |email|
        mail = UserMailer.with(email: email, group: @group).send_invitation
        mail.deliver_now
      end
      redirect_to group_path(@group)
    else
      render :new
    end
  end

  def my_groups
    @my_groups = current_user.groups
  end

  def update
    @group = Group.find(params[:id])
    @group.update(group_params)
    @group.votes.destroy
    @group.event_users.destroy
    # @group.event_ids = [125]
    redirect_to group_path(@group)
  end

  def destroy
  end

  private

  def join
  end

  def find_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :nearest, :date_event, :location, :email, :vote_duration, :proposition_duration)
  end
end
