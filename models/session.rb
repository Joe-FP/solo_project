require_relative( '../db/sql_runner' )

class Session

  attr_reader(:title, :session_date, :session_time, :duration_mins, :max_capacity, :min_capacity, :type, :intensity_level, :id)

  def initialize( options )
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @session_date = options['session_date']
    @session_time = options['session_time']
    @duration_mins = options['duration_mins'].to_i
    @max_capacity = options['max_capacity'].to_i
    @min_capacity = options['min_capacity'].to_i
    @type = options['type']
    @intensity_level = options['intensity_level']
  end

  def save()
    sql = "INSERT INTO sessions
    (title, session_date, session_time, duration_mins, max_capacity, min_capacity, type, intensity_level)
    VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING id"
    values = [@title, @session_date, @session_time, @duration_mins, @max_capacity, @min_capacity, @type, @intensity_level]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "UPDATE sessions SET
    (title, session_date, session_time, duration_mins, max_capacity, min_capacity, type, intensity_level) =
    ($1, $2, $3, $4, $5, $6, $7, $8)
    WHERE id = $9"
    values = [@title, @session_date, @session_time, @duration_mins, @max_capacity, @min_capacity, @type, @intensity_level, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM sessions
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def members()
    sql = "SELECT members.* FROM members INNER JOIN bookings ON bookings.member_id = members.id WHERE bookings.session_id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
    return results.map { |member| Member.new(member) }
  end

  def bookings()
    sql = "SELECT * FROM bookings WHERE session_id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
    return results.map { |booking| Booking.new(booking) }
  end

  def self.all()
    sql = "SELECT * FROM sessions"
    results = SqlRunner.run(sql)
    return results.map { |session| Session.new(session) }
  end

  def self.count()
    sql = "SELECT COUNT(*) FROM sessions"
    results = SqlRunner.run(sql)[0]['count'].to_i
  end

  def self.find(id)
    sql = "SELECT * FROM sessions WHERE id = $1"
    values = [id]
    results = SqlRunner.run(sql, values)
    return Session.new(results.first)
  end

  def self.delete_all
    sql = "DELETE FROM sessions"
    SqlRunner.run(sql)
  end

end
