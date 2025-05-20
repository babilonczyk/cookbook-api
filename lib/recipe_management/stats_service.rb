module RecipeManagement
  class StatsService
    GROUP_BY_TIMEFRAME = %w[week month]
    public_constant :GROUP_BY_TIMEFRAME

    TIME_FORMATS = {
      week: '%Y-%W',
      month: '%Y-%m'
    }.freeze

    # ------------------------------------------------------
    def call(recipes:, timeframe:)
      return { error: 'Invalid time frame. Expected: `week`, or `month`' } unless GROUP_BY_TIMEFRAME.include?(timeframe)

      time_format = TIME_FORMATS[timeframe.to_sym]

      stats = recipes
              .joins(:categories)
              .left_outer_joins(:likes)
              .group('categories.name', "strftime('#{time_format}', recipes.created_at)")
              .select(
                'categories.name AS category_name',
                "strftime('#{time_format}', recipes.created_at) AS time_group",
                'COUNT(DISTINCT recipes.id) AS recipe_count',
                'COUNT(likes.id) AS total_likes'
              )
              .order('time_group DESC')

      stats = stats.map do |d|
        year, month, week = get_time_group_values(d, timeframe)

        {
          category: d.category_name,
          timeframe: timeframe,
          year: year,
          month: month,
          week: week,
          recipe_count: d.recipe_count.to_i,
          total_likes: d.total_likes.to_i
        }
      end

      { stats: stats }
    rescue StandardError => e
      { error: e.message }
    end

    private

    # ------------------------------------------------------
    def get_time_group_values(data, timeframe)
      year, period = data.time_group.split('-')
      year = year.to_i

      month = nil
      week = nil

      case timeframe
      when 'week'
        week = period.to_i
        month = nil
      when 'month'
        month = period.to_i
        week = nil
      else
        raise ArgumentError, "Invalid timeframe: #{timeframe}"
      end

      [year, month, week]
    end
  end
end
