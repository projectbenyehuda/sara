class TimelinesController < ApplicationController
  def index
  end

  def data
    render json:
      [
        {
          id: 1,
          title: 'Birth',
          subtitle: 'Zgierz, Poland',
          from: {
            year: 1859,
            month: 12,
            day: 31
          }
        },
        {
          id: 2,
          title: 'First published article',
          from: {
            year: 1876
          }
        },
        {
          id: 3,
          title: 'Studied philology, philosophy and the history of art',
          subtitle: 'University of Breslau',
          from: {
            year: 1895
          },
          to: {
            year: 1910
          }
        },
        {
          id: 4,
          title: 'Death',
          subtitle: 'Berlin, Germany',
          from: {
            year: 1922,
            month: 8,
            day: 4
          }
        }
      ]
  end
end
