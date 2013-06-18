module GalaxiesHelper
  def galaxy_types(current)
    options_for_select([
        ['All',nil],
        ['Spiral','S'],
        ['Spiral Barred','SB'],
        ['Elliptical','E'],
        ['Lenticular','L'],
        ['Irregular','I'],
                       ],current)
  end
end

