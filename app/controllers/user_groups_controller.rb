class UserGroupsController < ApplicationController

  def new
    # if params[:user_id].nil?
      # @user = User.create(user:)
    # else
    # @user = current_user
    if params[:user_id]
    @user = User.find(params[:user_id])
       @group = Group.find(params[:group_id])
     if UserGroup.where(group: @group, user: @user).size >= 1
        # raise
       else
        # raise
            @user_group = UserGroup.create(user: @user, group: @group)
          end
    if @user.photo
    else
      @user[:photo] = "festeam-logo.png"
    end
    message = " #{@user.email} à rejoint le groupe #{@group.name}"
    ActionCable.server.broadcast("group_#{@group.id}", { user: @user, photo: helpers.image_path(@user.photo), flash_message: message })

    redirect_to group_path(@group)
  else
     @user = current_user
     @group = Group.find(params[:group_id])
      # On empeche un utilisateur de se connecter 2 fois sur un meme group
       # array_email = group.email.split('"')

       #     array_email.delete_at(0)
       #     array_email.delete_at(-1)
       #     array_email.delete('"')
       #     array_email.delete(',')

       if UserGroup.where(group: @group, user: @user).size >= 1
        # raise
       else
        # raise
          # array_email.each_with_index do |email, i|
            # if i.even? || array_email.size == i+1

            @user_group = UserGroup.create(user: @user, group: @group)

            # end
          end



    # @user_group = UserGroup.create(user: @user, group: @group)
    if @user.photo
    else
      @user[:photo] = "festeam-logo.png"
    end
    message = " #{@user.email} à rejoint le groupe #{@group.name}"
    ActionCable.server.broadcast("group_#{@group.id}", { user: @user, photo: helpers.image_path(@user.photo), flash_message: message })

    redirect_to group_path(@group)

    # cookies[:join_group] = params[:group_id]
    # raise
    # redirect_to new_user_registration_path
  end
  # end
    # if @user.photo
    # else
      # @user[:photo] = "festeam-logo.png"
    # end
    # raise
    # @adverts = @user.adverts
    # @applications = @user.forms

  end

end
