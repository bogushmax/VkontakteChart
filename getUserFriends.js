var result = {friends: {}};

VK.Api.call('users.get', {uid: '13724351', fields: ['schools', 'universities']}, function(r) {
  var currentUser = r.response[0];
  VK.Api.call('friends.get', {fields: ['schools', 'universities']}, function(r) {
    var friends = r.response, i;
    for (i in friends) {
      var k, j;
      var isAdded = false;
      var friend  = friends[i];
      var id      = friend.uid;
      result.friends[id] = {firstName: friend.first_name};
      for (k in friend.schools) {
        for (j in currentUser.schools) {
          if (friend.schools[k].id == currentUser.schools[j].id) {
            result.friends[id].group = 'schools';
            isAdded = true;
            break;
          }
        }
        if (isAdded) break;
      }
      if (!isAdded) {
        for (k in friend.universities) {
          for (j in currentUser.universities) {
            if (friend.universities[k].id == currentUser.universities[j].id) {
              result.friends[id].group = 'universities';
              isAdded = true;
              break;
            }
          }
          if (isAdded) break;
        }
      }
      if (!isAdded) {
        result.friends[id].group = 'others';
      }
      var callback = function(id) {
        return function(r) {
          var friendFriends = r.response;  
          result.friends[id].friends = friendFriends;
        }
      }
      VK.Api.call('friends.get', {uid: id}, callback(id));
    }
  });
});
