class GeneticAlgorithm
  # Algorithm structure:
  # 
  # population: need to initialize and pass through each generation
  # mutation: takes in chromosome and returns new chromosome
  # crossover: takes in chromosome and returns new chromosome
  # fitness function: takes in chromosome and returns value

  def initialize(mutation_rate = 0.1, crossover_rate = 0.7, max_generations = 100, num_cities = 30, population_size = 20, tourney_size = 3)
    @mutation_rate = mutation_rate
    @crossover_rate = crossover_rate
    @max_generations = max_generations
    @num_cities = num_cities
    @population_size = population_size
    @population = initialize_population
    @city_map = generate_city_map
    @tourney_size = tourney_size
  end

  def print_crossover_rate
    @crossover_rate
  end

  def population
    @population
  end

  def city_map
    @city_map
  end

  def generate_city_map
    city_map = []
    1.upto(@num_cities) do
      city_map << []
    end
    city_map.each_with_index do |city, index|
      1.upto(@num_cities) do |num|
        if index == (num - 1)
          city << 0
        else
          city << Random.rand(1000)
        end
      end
    end
    return city_map
  end

  def initialize_population
    @population = []
    1.upto(@population_size) do
      @population << generate_chromosome
    end
    @population
  end

  def generate_chromosome
    (1..@num_cities).to_a.shuffle
  end

  def select_for_crossover
    indices = []
    @population.each_with_index do |chromosome, index|
      if Random.rand < @crossover_rate
        indices << index
      end
    end
    indices.shuffle
  end

  def select_for_mutation
    indices = []
    @population.each_with_index do |chromosome, index|
      if Random.rand < @mutation_rate
        indices << index
      end
    end
    indices
  end

  def compute_fitness(chrom)
    fitness_val = 0
    prev_city = chrom.first
    chrom.each do |city_num|
      val_to_add = city_map[prev_city - 1][city_num - 1]
      fitness_val += val_to_add
      prev_city = city_num
    end
    fitness_val
  end

  def best_by_fitness(chroms)
    fitness_vals = []
    chroms.each do |chrom|
      fitness_vals << compute_fitness(chrom)
    end
    best_fitness = fitness_vals.min
    best_index = fitness_vals.index(best_fitness)
    chroms[best_index]
  end

  def select_by_tournament
    old_population = @population
    new_population = []
    # puts "computing tourneys of #{@tourney_size}"
    1.upto(@population_size) do
      chroms_to_judge = []
      1.upto(@tourney_size) do
        chroms_to_judge << old_population[Random.rand(@population_size)]
      end
      new_chrom = best_by_fitness(chroms_to_judge)
      new_population << new_chrom
    end
    @population = new_population
  end

  def crossover(index1, index2)
    # Don't swap if we've reached the end of the population
    unless (index1 && index2).nil?
      # puts ""
      # puts "Crossing over #{index1} and #{index2}"

      # Isolate chromosomes
      first = @population[index1]
      second = @population[index2]

      # Generate swap points, then make sure they're in order
      shift_index1 = Random.rand(@num_cities - 1)
      shift_index2 = Random.rand(@num_cities - 1)
      shift_start = [shift_index1, shift_index2].min
      shift_end = [shift_index1, shift_index2].max
      shift_distance = (shift_index1 - shift_index2).abs
      # puts "Crossing over #{first} and #{second}"
      # puts "Crossing over from #{shift_start} to #{shift_end}"
      # puts ""

      # Isolate values we're swapping
      first_swap_values = first.slice(shift_start, shift_distance)
      # puts "First swap values: #{first_swap_values}"
      second_swap_values = second.slice(shift_start, shift_distance)
      # puts "Second swap values: #{second_swap_values}"
      # puts ""
      first_with_dups = [first.slice(0, shift_start), second_swap_values, first.slice(shift_end, first.length)].flatten
      # puts "First with dups: #{first_with_dups}"
      second_with_dups = [second.slice(0, shift_start), first_swap_values, second.slice(shift_end, second.length)].flatten
      # puts "Second with dups: #{second_with_dups}"
      # puts ""

      missing_vals = first_swap_values - second_swap_values
      second_swap_values.each_with_index do |val, index|
        if first_swap_values.index(val).nil?
          first_with_dups[first.index(val)] = missing_vals.shift
        end
      end

      missing_vals = second_swap_values - first_swap_values
      first_swap_values.each_with_index do |val, index|
        if second_swap_values.index(val).nil?
          second_with_dups[second.index(val)] = missing_vals.shift
        end
      end

      # puts "Final first: #{first_with_dups}"
      # puts "Final second: #{second_with_dups}"
      # puts ""
      
      @population[index1] = first_with_dups
      @population[index2] = second_with_dups
    end
  end

  def mutate(chrom_index)
    chrom = @population[chrom_index]
    swap_point = Random.rand(@num_cities - 1)
    # puts "Mutating at index #{chrom_index} position #{swap_point}"    
    second_point = (swap_point == (@num_cities - 1)) ? 0 : (swap_point + 1)
    # puts "second mutation point at #{second_point}"

    temp = chrom[swap_point]
    chrom[swap_point] = chrom[second_point]
    chrom[second_point] = temp

    @population[chrom_index] = chrom

  end

  def execute
    1.upto(@max_generations) do |index|
      best = best_by_fitness(@population)
      puts "Best chrom in gen #{index} is #{best} with a fitness of #{compute_fitness(best)}"
      select_by_tournament
      indices = select_for_crossover
      while(!indices.empty?) do
        crossover(indices.shift, indices.shift)
      end
      indices = select_for_mutation
      while(!indices.empty?) do
        mutate(indices.shift)
      end
    end
  end

end