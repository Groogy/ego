module PathFinder
  DIRECTIONS = {
    Boleite::Vector2i.new(0, -1), Boleite::Vector2i.new( 1, 0),
    Boleite::Vector2i.new(0,  1), Boleite::Vector2i.new(-1, 0)
  }

  class Node
    getter pos : Map::Pos
    property prev : Node?
    property cost : Float64
    getter heuristic : Float64

    def initialize(@pos, @prev, @cost, @heuristic)
    end
  end

  def self.quick_search(world, start, target)
    explored = Deque(Node).new
    frontier = Deque(Node).new 
    target_pos = target.position.point
    heuristic = Boleite::Vector.magnitude (target_pos.to_vector - start.to_vector).to_f
    frontier << Node.new start, nil, 0.0, heuristic
    while !frontier.empty?
      node = frontier.shift
      if node.pos == target_pos
        return self.build_path node
      end
      explored.push node
      DIRECTIONS.each do |dir|
        neigh = node.pos + dir
        next if !world.within_boundraries? neigh
        cost = node.cost + world.movement_cost node.pos, neigh
        heuristic = Boleite::Vector.magnitude (target_pos.to_vector - neigh.to_vector).to_f
        index = explored.index(offset:0) { |n| n.pos == neigh }
        if index
          e = explored[index]
          if e.cost > cost
            e.prev = node
            e.cost = cost
          end
        else
          index = frontier.index(offset:0) { |n| n.pos == neigh }
          if index
            f = frontier[index]
            if f.cost > cost
              f.prev = node
              f.cost = cost
            end
          else
            frontier << Node.new neigh, node, cost, heuristic
          end
        end
      end
    end
    return nil
  end

  def self.broad_search(world, start, length, tester)
    explored = Deque(Node).new length * length
    frontier = Deque(Node).new 
    frontier << Node.new start, nil, 0.0, 0.0
    while !frontier.empty?
      node = frontier.shift
      explored.push node

      if result = tester.call world, node.pos
        return self.build_path node
      end

      DIRECTIONS.each do |dir|
        neigh = node.pos + dir
        next if !world.within_boundraries? neigh
        next if Boleite::Vector.square_magnitude((start - neigh).to_vector) >= length * length

        cost = node.cost + world.movement_cost node.pos, neigh
        neighbor = Node.new neigh, node, cost, 0.0
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

  def self.broad_search_entity(world, start, length, tester)
    explored = Deque(Node).new length * length
    frontier = Deque(Node).new 
    frontier << Node.new start, nil, 0.0, 0.0
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
        neighbor = Node.new neigh, node, cost, 0.0
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

  def self.build_path(node)
    path = Path.new
    while node
      path.add node.pos
      node = node.prev
    end
    path
  end
end