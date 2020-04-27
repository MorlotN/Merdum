class GroupsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :index]
  before_action :find_group, only: [:show]
  RESULT_ALL = Hash.new { |hash, key| hash[key] = 0 }

  def index
    @events = EventHome.new(cookies).result
    @group = Group.all
    @my_groups = []
    @group.each do |group|
    if group.email.include?("\"#{current_user.email}\"")
    @my_groups << group
# @my_groups = current_user.groups
  end
end
    # raise


  #   if @my_group && @my_group.event_users
  #    @my_group.event_users.each_with_index do |event_user, index|
  #     RESULT_ALL["#{event_user.event_id}"] = event_user.score
  #   end
  #   @result_all = RESULT_ALL.max_by{|k,v| v}
  # else
  # end
#   @win = Event.find_by(id: @result_all[0])
#   @win.photo
# raise
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

#     if @result_all
#       @win = Event.find_by(id: @result_all[0])
#       Group.update(photo: @win.photo_url)
# end

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
    # p "avant group.new"
    @group = Group.new(group_params)

    @group.email = emails

    @group.email.insert(-2, ", \"#{current_user.email}\"")

    # cookies[:date_start] = @group.date_event
    # @group.user = current_user
    # raise
    if @group.save

      @group.users << current_user

      JSON.parse(@group.email).each do |email|

        # if email == current_user.email

        # else

        mail = UserMailer.with(email: email, group: @group).send_invitation

        mail.deliver_now

      end

      # end

        # @group.email.insert(-2, ", \"#{current_user.email}\"")
        # raise
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
    # @event_user = EventUser.find(@group)
    # raise
    @group.update(group_params)
    # @group.user_ids = []
    if EventUser.find_by(group_id: params[:id]).nil?
    else
     all_event = @group.events
      all_event.each do |event|
    EventUser.find_by(group_id: params[:id]).destroy
    @group.votes.destroy
    end
  end
# raise
    # @group.votes = []
    # map do |score|
    #   score = 0
    # end
    # raise
    # @group.events = []
    @group.users = []
    emails = []
    @group.event_users.destroy
    # @group.event_ids.destroy
    params["invit-email"].nil? ? emails = [] : emails = params["invit-email"]
    emails << params["group"]["email"]
          @group.users << current_user
      JSON.parse(@group.email).each do |email|
        mail = UserMailer.with(email: email, group: @group).send_invitation
        mail.deliver_now
      end
    redirect_to group_path(@group)
  end

  def destroy
    @group = Group.find(params[:id])
    # @my_group = current_user.groups
    # @my_group.delete(@group)
    @group.delete
    # @user_group = UserGroup.find_by(group_id: @group.id, user_id: current_user.id)


    # @group.email.gsub!(/\"#{current_user.email}\"/, "")
    # @user_group.delete



    # raise
    redirect_to groups_path
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
