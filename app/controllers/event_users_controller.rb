class EventUsersController < ApplicationController
  def new
    @event_user = EventUser.new
    @group = Group.find(params[:group_id])
    cookies[:address] = @group.location
    cookies[:date_start] = @group.date_event
    cookies[:nearest] = @group.nearest
    @events = EventHome.new(cookies).home

    # @events = @events.geocoded #returns events with coordinates
     if params[:query].present?
      sql_query = "name ILIKE :query OR description ILIKE :query OR address ILIKE :query"
      @events = @events.where(sql_query, query: "%#{params[:query]}%")
    else
      @events = @events
    end

    @markers = @events.map do |event|
      {
        lat: event.lat,
        lng: event.long,
        name: event.name,
        address: event.address,
        category: event.category,
        details: event_path(event),
        photo_url: event.photo_url,
        # infoWindow: render_to_string(partial: "info_window", locals: { event: event })
      }
    end


end

  def create
    group = Group.find(params[:group_id])
    event = Event.find(params[:event_id])
    EventUser.create(
      group: group, event: event, user: current_user
    )
    redirect_to group_path(params[:group_id])
  end

  def destroy
    @group = EventUser.find_by(group_id: params[:group_id], user_id: current_user.id)
    # @event = @group.event_id
    # raise
    @group.destroy
    # raise

    redirect_to groups_path
  end
end
