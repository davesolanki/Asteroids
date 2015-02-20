


class GameWindow < Gosu::Window
	attr_accessor :controller, :play_state

  include Chingu
	include Gosu
  def initialize
  	@projectiles = []
    super(640, 480, false)
    @background_image = Gosu::Image.new(self, "assets/background.png", true)
    @life_image = Gosu::Image.new(self, "assets/ship.gif", false)
    @sound = Gosu::Sample.new(self, 'assets/pew.m4a')
    @font = Gosu::Font.new(self, 'Inconsolata-dz', 24)
    @high_score_list = HighScoreList.load(:size => 3)
    @player = Player.new(self)
    @asteroids = []

  	@game_in_progress = false
    title_screen


    @play_state = 0
  end

  def title_screen
    number_asteroids(3)
    # @asteroids += @asteroids[0].kill
    # @asteroids += @asteroids[1].kill
    # @asteroids += @asteroids.last.kill
  end


  def setup_game
    @player = Player.new(self)
    @level = 1
    @initial_asteroid_count = 3
    number_asteroids(@initial_asteroid_count)
    @projectiles = []
    @game_in_progress = true
  end

  def update
  	@projectiles.each {|projectile| projectile.move}
  	@projectiles.reject!{|projectile| projectile.dead?}
  	@asteroids.each {|asteroid| asteroid.move}
  	@asteroids.reject!{|asteroid| asteroid.dead?}
  	detect_collisions
  	control_player unless @player.dead?
  	@player.move
  	next_level if @asteroids.size == 0
		if button_down? Gosu::KbR
	      title_screen unless @game_in_progress == false
	      @game_in_progress = false
	  end

		if button_down? Gosu::KbQ
      		close
    end

	    if button_down? Gosu::KbS
 			setup_game unless @game_in_progress
		end   

		if @game_in_progress
		    	@play_state -= 1
		end

    return unless @game_in_progress
	end

	# happens immediately after each iteration of the update method
	def draw
		if !@game_in_progress
	      @font.draw("ASTEROIDS", 175, 120, 50, 2.8, 2.8, 0xffffffff)
	      @font.draw("press 's' to start", 210, 320, 50, 1, 1, 0xffffffff)
	      @font.draw("press 'q' to quit", 216, 345, 50, 1, 1, 0xffffffff)
	  end

    if @player.lives == 0
      highscorepg
		  @font.draw("press 'r' to restart", 195, 320, 50, 1, 1, 0xffffffff)
		  @font.draw("press 'q' to quit", 210, 345, 50, 1, 1, 0xffffffff)
      return
    end

		@projectiles.each {|projectile| projectile.draw}
		@background_image.draw(0, 0, 0)
		@player.draw unless @player.dead?
		@asteroids.each {|asteroid| asteroid.draw}
		draw_lives
		@font.draw(@player.score, 10, 10, 50, 1.0, 1.0, 0xffffffff)
	end

	def draw_lives
	  return unless @player.lives > 0
	  x = 10
	  @player.lives.times do 
	    @life_image.draw(x, 400, 0)
	    x += 20
	  end
	end

  def control_player
    if button_down? Gosu::KbLeft
      @player.turn_left
    end
    if button_down? Gosu::KbRight
      @player.turn_right
    end
    if button_down? Gosu::KbUp
      @player.accelerate
    end
    if button_down? Gosu::KbDown
      @player.deccelerate
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @sound.play
      @projectiles << Projectile.new(self, @player) unless @player.dead?
    end
  end

  def collision?(object_1, object_2)
    hitbox_1, hitbox_2 = object_1.hitbox, object_2.hitbox
    common_x = hitbox_1[:x] & hitbox_2[:x]
    common_y = hitbox_1[:y] & hitbox_2[:y]
    common_x.size > 0 && common_y.size > 0 
  end

  def detect_collisions
    @asteroids.each do |asteroid| 
      if collision?(asteroid, @player)
        @player.kill && @play_state = 0 unless @play_state > 0 || @player.lives == 0
      end
    end
    @projectiles.each do |projectile| 
      @asteroids.each do |asteroid|
        if collision?(projectile, asteroid)
          projectile.kill
          @asteroids += asteroid.kill
          @player.score += asteroid.points
        end
      end
    end
     @projectiles.each do |projectile| 
      @asteroids.each do |asteroid|
        if collision?(projectile, asteroid)
          projectile.kill
          asteroid.kill
        end
      end
    end
  end

  def number_asteroids(t)
  	@asteroids = []
  	t.times do
  		@asteroids = @asteroids.push(Asteroid.new(self))
  	end
  end

  def next_level
  	@initial_asteroid_count += 1
  	number_asteroids(@initial_asteroid_count) 
  end

  def highscorepg
        @font.draw("High Score", 200, 50, 50, 2.0, 2.0, 0xffffffff)
    @high_score_list.each_with_index do |high_score, index|
      y = index * 25 + 150
      @font.draw(high_score[:name], 200, y, 50, 1, 1, 0xffffffff)
      @font.draw(high_score[:score], 400, y, 50, 1, 1, 0xffffffff)
    end
  end
end

