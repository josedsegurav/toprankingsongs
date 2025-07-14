class DailyRankingsController < ApplicationController
    @rankings = DailyRanking.includes(:track, :country).all
end
