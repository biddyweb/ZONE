require 'json'

class SearchesController < ApplicationController
  # GET /searches
  # GET /searches.json
  def index
    if !user_signed_in?
      flash[:error] = t("devise.failure.unauthenticated")
      redirect_to :back
      return
    end
    @searches = Search.where(:user_id => current_user.id).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @searches }
    end
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    redirect_to items_path(:search => params[:id],:notice => notice )
  end

  # GET /searches/new
  # GET /searches/new.json
  def new
    @search = Search.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/1/edit
  def edit
    @search = retrieveSearchFromForm(params)
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = retrieveSearchFromForm(params)
    respond_to do |format|
      if @search.save
        format.html { redirect_to items_path(:search => @search.id, :itemid => params[:itemId] )  }
        format.json { render json: @search, status: :created, location: @search }
      else
        format.html { render action: "new" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /searches/1
  # PUT /searches/1.json
  def update
    @search = retrieveSearchFromForm(params)

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to items_path(:search => @search.id )  }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      format.html { redirect_to searches_url }
      format.json { head :no_content }
    end
  end

  def selectSources
    @sources = current_user.getSources
    render  :layout => 'empty'
  end

  def retrieveSearchFromForm(form)
    if user_signed_in?
      userId = current_user.id
    else
      userId=0
    end

    search = Search.new
    if form[:itemId] != ''
      search = Search.find(form[:itemId])
      search.filters = Array.new
      search.sources = Array.new
    else
      search = Search.new
    end

    search.build_from_form(form,userId)
    return search
  end
end
