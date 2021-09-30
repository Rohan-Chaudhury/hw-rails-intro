class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @distinct_ratings=Movie.distinct.pluck("rating")
      @new_movies=Movie
      @get_sorting_type=params[:sort_type]
      
  
      if params[:ratings]
        @ratings_filtered=params[:ratings]
        @ratings_filtered_keys=@ratings_filtered.keys
        @new_movies=@new_movies.where(rating: @ratings_filtered_keys)
        session[:ratings]=params[:ratings]
      elsif session[:ratings]
        @ratings_filtered=session[:ratings]
        @ratings_filtered_keys=@ratings_filtered.keys
        @new_movies=@new_movies.where(rating: @ratings_filtered_keys)   
      else
        @ratings_filtered=@distinct_ratings
      end
      
      if @get_sorting_type
        @new_movies=@new_movies.all.order(@get_sorting_type)
        session[:sort_type]=@get_sorting_type
      elsif session[:sort_type]
        @get_sorting_type=session[:sort_type]
        @new_movies=@new_movies.all.order(@get_sorting_type)
      else
        @new_movies = @new_movies.all
      end
      
      if (session[:ratings] or sessions[:sort_type]) and (!params[:sort_type] and !params[:ratings])
        if session[:ratings]
          params[:ratings]=session[:ratings]
        end
        if session[:sort_type]
          params[:sort_type]=session[:sort_type]
        end
        redirect_to movies_path(params)      
      end
        
      @movies=@new_movies
      
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end