module PathFinder
  DIRECTIONS = {
    Boleite::Vector2i.new(0, -1), Boleite::Vector2i.new( 1, 0),
    Boleite::Vector2i.new(0,  1), Boleite::Vector2i.new(-1, 0)
  }

  class Node
    getter pos : Map::Pos
    getter prev : Node?
    getter cost : Float64

    def initialize(@pos, @prev, @cost)
    end
  end

  def self.broad_search(world, start, length, tester)
    explored = Deque(Node).new length * length
    frontier = Deque(Node).new 
    frontier << Node.new start, nil, 0.0
    while !frontier.empty?
      node = frontier.shift
      explored.push node

      if result = tester.call world, node.pos
        return result
      end

      DIRECTIONS.each do |dir|
        neigh = node.pos + dir
        next if !world.within_boundraries? neigh
        next if Boleite::Vector.square_magnitude((start - neigh).to_vector) >= length * length

        cost = node.cost + world.movement_cost node.pos, neigh
        neighbor = Node.new neigh, node, cost
        unless explored.find { |n| n.pos == neigh }
          index = frontier.index(offset:0) { |n| n.pos == neigh }
          if index
            frontier[index] = neighbor if frontier[index].cost > cost
          else
            frontier.push neighbor
          end
        end
      end
    end
    nil
  end
end