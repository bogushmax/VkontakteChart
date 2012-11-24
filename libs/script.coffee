##
String::capitalize = -> this.charAt(0).toUpperCase() + this.slice(1);
fromPolar          = (radius, angle) -> {x: radius * Math.cos(angle), y: radius * Math.sin(angle)}
##

svgSize   = { width: 1024, height: 768 }
axis      = { names:  [ 'schools', 'universities', 'others' ], length: 400, radius: 20, offset: 50 }
nodes     = { radius: 2 }

# Scales
axis.angle = d3.scale.linear()
                     .domain([0, axis.names.length])
                     .range([0, 360])
axis.position = d3.scale.linear()
                        .range([axis.radius + axis.offset, axis.length - axis.offset])

chart = d3.select('#chart')
svg   = chart.append('svg:svg')
             .attr('width',  svgSize.width)
             .attr('height', svgSize.height)
             .append('g')
             .attr('transform', "translate(#{svgSize.width/2}, #{svgSize.height/2})")
d3.json 'data/friends-list.json', (nodes) ->
  friends = nodes.friends
  # Generate indecies
  counters = { schools: 0, universities: 0, others: 0 }
  for id, friend of friends
    friend.index = counters[friend.group]++
  
  friendships = []
  for friend of friends
    for friendOfFriend of friends[friend].friends
      if friends[friends[friend].friends[friendOfFriend].toString()]?
        friendship = [friend,friends[friend].friends[friendOfFriend].toString()]
        unless friendship.reverse() in friendships
          friendships[friendship] = true
      
  # Draw axis
  svg.selectAll('.axis')
     .data(axis.names)
     .enter().append('svg:line')
             .attr('class', 'axis')
             .attr('transform', (d,i) -> "rotate(#{axis.angle(i)})")
             .attr('x1', axis.radius)
             .attr('x2', axis.length)

  getFriendPosition = (friend) ->
    axis.position.domain([0, counters[friend.group] - 1])
    axis.position(friend.index)

  # Draw nodes
  svg.append('g')
     .attr('id', 'nodes')
        .selectAll('.node')
        .data(d3.values(friends))
        .enter().append('svg:circle')
                .attr('class', 'node')
                .attr('transform', (d) -> "rotate(#{axis.angle(axis.names.indexOf(d.group))})")
                .attr('cx', getFriendPosition)
                .attr('r', 4)
  
  friendshipPath = d3.svg.line()
                              .interpolate('bundle')
                              .tension(.8)
                              .x((d) -> d.radius * Math.cos(d.angle * Math.PI / 180))
                              .y((d) -> d.radius * Math.sin(d.angle * Math.PI / 180))
  friendshipsSplines = []
  for friendship of friendships
    friendship = friendship.split ','
    startNode  = {}
    middleNode = {}
    endNode    = {}
    friend = (i) -> friends[friendship[i]]
    startNode = {radius: getFriendPosition(friend(0)), angle: axis.angle(axis.names.indexOf(friend(0).group))}
    endNode   = {radius: getFriendPosition(friend(1)), angle: axis.angle(axis.names.indexOf(friend(1).group))}
    if startNode.angle == endNode.angle
      middleNode.radius = startNode.radius + (startNode.radius - startNode.radius) / 2 + 5
      middleNode.angle  = startNode.angle - 20
    friendshipsSplines.push [startNode, middleNode, endNode]
  
  # Draw bounds
  svg.append('g')
     .attr('id', 'friendships')
        .selectAll('.friendship')
        .data(d3.keys(friendships))
        .enter().append('svg:path')
                .attr('class', 'friendship')
                .attr('d', (d, i) -> friendshipPath(friendshipsSplines[i]))
                
  # Draw badges
  ###
  svg.append('g')
     .attr('id', 'badges')
        .selectAll('.badges')
        .data(axis.names)
        .enter().append('svg:text')
                .attr('class', 'badge')
                #.attr('transform', (d, i) -> "rotate(#{axis.angle(i)})")
                .attr('x', (d, i) -> (axis.length + 10) * Math.cos(axis.angle(i) * Math.PI / 180))
                .attr('y', (d, i) -> (axis.length + 10) * Math.sin(axis.angle(i) * Math.PI / 180) + 10)
                .text((d) -> d)
  ###