# 🎯 SCREEN QUICK REFERENCE - TEACHER QUESTIONS ANSWERED

## **LOGIN SCREEN** (`login_screen.dart`)
**Lines: ~650** | **Purpose:** Authentication

### Trivia
- Uses **two forms in one** (login tab & signup tab)
- Passwords validated for **minimum 6 characters**
- Email validated using **regex pattern**
- Demo users **hardcoded** in ApiService

### Teacher might ask...

**Q: "How do I change the demo username?"**
- Go to: `lib/services/api_service.dart` line ~20
- Find: `_mockUsers` list
- Change: `'email': 'citizen@demo.com'` to your email
- Done! (No other code changes needed)

**Q: "Add password strength meter"**
- Find: `_buildPasswordField()` method
- Add under password field:
```dart
if (_passwordController.text.length < 6) {
  Text("Weak password", style: TextStyle(color: Colors.red));
} else if (_passwordController.text.length < 10) {
  Text("Good password", style: TextStyle(color: Colors.orange));
} else {
  Text("Strong password", style: TextStyle(color: Colors.green));
}
```

**Q: "Why are there two controllers for signup?"**
- `_nameController` = collect name
- `_phoneController` = collect phone
- `_emailController` = collect email  
- `_passwordController` = collect password
- Each TextField needs its own controller to get the value

**Q: "Where's the 'Remember Me' logic?"**
- Line ~555: `_buildRememberMeCheckbox()`
- Just stores `_rememberMe` boolean
- (Actually saved via SharedPreferences in real backend)

---

## **HOME SCREEN** (`home_screen.dart`)
**Lines: ~1300** | **Purpose:** Citizen dashboard

### Trivia
- **Real weather data** from OpenWeatherMap API 
- Beautiful gradient **sunset effect** on weather card
- Quick actions show **modal bottom sheet** for extra options
- Reports use **PageView** for swipeable detail view

### Teacher might ask...

**Q: "Change the weather card background color"**
- Find: Line ~230 `gradient: LinearGradient(colors: [`
- Change the color values:
```dart
colors: [
  Color(0xFF0D47A1),  // Dark blue - CHANGE THIS
  Color(0xFF1565C0),  // Medium blue - OR THIS
  Color(0xFF42A5F5),  // Light blue - OR THIS
],
```

**Q: "Add a new quick action button"**
- Find: Line ~170 `final actions = [`
- Add new item in the list:
```dart
{
  'label': 'My New Button',
  'icon': Icons.my_icon,
  'color': AppTheme.primary,
  'route': 'my_route'
},
```
- Then add case in `app.dart` to handle that route

**Q: "How does auto-refresh work?"**
- Line ~60: `_loadReports()` - fetches all reports
- Line ~40: Called in `initState()` on first load
- Line ~910: Refresh button calls `_refreshData()`
- `_refreshData()` calls `_loadReports()` + `setState()`

**Q: "Remove the weather card entirely"**
- In `build()` method, find section with `_buildMainWeatherCard()`
- Delete/comment out:
```dart
_buildMainWeatherCard(context, isTablet),
const SizedBox(height: 24), // Remove spacing too
```

---

## **COMMUNITY SCREEN** (`community_screen.dart`)
**Lines: ~700** | **Purpose:** Social feed of reports

### Trivia
- **Upvotes/downvotes are toggles** (tap again to remove)
- Comments show in **BottomSheet modal**
- Can't upvote AND downvote same post (toggles off other)
- **Refresh button** reloads all posts from ApiService

### Teacher might ask...

**Q: "How do upvotes actually work?"**
```dart
// Line ~60: When user taps upvote
_upvote(String id) async {
  await ApiService.upvoteReport(id); // Call backend
  setState(() {
    _loadReports(); // Reload to show new count
  });
}
```
- ApiService increments the count
- `setState()` rebuilds UI
- Button color changes (full color if user voted)

**Q: "Add a comment field to each post"**
- Find: `_buildPostActions()` method
- Find line: `_buildActionButton(Icons.comment_outlined, ...)`
- Change from: `() => _addComment(report['id'])`
- To: `() => _viewComments(report['id'])` (already does this!)

**Q: "Change the credibility color scheme"**
- Find: `_credibilityColor()` method
- Change thresholds:
```dart
Color _credibilityColor(int score) {
  if (score >= 75) return Colors.green;    // 75+ = green
  if (score >= 50) return Colors.orange;   // 50-74 = orange
  return Colors.red;                       // <50 = red
}
```

**Q: "Remove downvote button"**
- Find: `_buildPostActions()` method
- Remove this section:
```dart
_buildActionButton(
  Icons.thumb_down_outlined,
  '$downvotes',
  AppTheme.error,
  () => _downvote(report['id']),
),
const SizedBox(width: 16),
```

---

## **MAP SCREEN** (`map_screen.dart`)
**Lines: ~500** | **Purpose:** Geographic disaster visualization

### Trivia
- Uses **OpenStreetMap** (free, no API key)
- **Markers cluster** when zoomed out
- Only shows **Rawalpindi/Islamabad area** (geofenced)
- **Color-coded by type** (Red=Fire, Blue=Flood, etc.)

### Teacher might ask...

**Q: "How do I change the map center location?"**
- Find: Initial map position
- Look for: `initialCenter: LatLng(33.xx, 73.xx)`
- Change to new coordinates:
```dart
initialCenter: LatLng(33.7294, 73.0931), // Islamabad
```

**Q: "Add a button to go to user's location"**
- Add to AppBar:
```dart
IconButton(
  icon: Icon(Icons.my_location),
  onPressed: () async {
    final pos = await LocationWeatherService.getCurrentPosition();
    // Move map to pos
  }
)
```

**Q: "Change marker colors"**
- Find: `_getMarkerColor()` method
- Change:
```dart
case 'FLOOD':
  return Colors.blue;  // CHANGE THIS COLOR
case 'FIRE':
  return Colors.red;
```

---

## **AI CHATBOT** (`ai_chatbot_screen.dart`)
**Lines: ~350** | **Purpose:** Emergency guidance chatbot

### Trivia
- **6 pre-fed quick actions** (buttons above keyboard)
- **Keyword-based AI** (checks if message contains word)
- Quick actions **instant** (no delay), messages have **800ms delay**
- All responses stored in `_messages` list

### Teacher might ask...

**Q: "Add a new quick action button"**
```dart
// Find: quickResponses = Map at line ~30
// Add new entry:
'🌪️ Tornado Safety': "**Tornado Safety:**\n\n"
    "1. Go to basement\n"
    "2. Stay away from windows\n"
    "etc..."
```
- Button automatically appears! (No other changes)

**Q: "Change the 'earthquake' AI response"**
- Find: `_getAIResponse()` method
- Find: `if (message.contains('earthquake'))`
- Change the return text to your message

**Q: "Add a new keyword trigger"**
- In `_getAIResponse()` method:
```dart
} else if (message.contains('tsunami')) { // NEW KEYWORD
  return "Tsunami safety information...";
} else if (message.contains('earthquake')) {
```

**Q: "Remove a quick action button"**
- Remove from `quickResponses` map:
```dart
// DELETE THIS ENTIRE ENTRY:
'🏚️ Earthquake Safety': "...",
```
- Button auto-disappears

**Q: "Change the delay for AI response"**
- Find: `Future.delayed(const Duration(milliseconds: 800), () {`
- Change 800 to your milliseconds (1000 = 1 second)

**Q: "Make quick action buttons bigger"**
- Find: `_buildQuickActions()` method
- Find: `SingleChildScrollView` with chips
- Wrap in:
```dart
Padding(
  padding: EdgeInsets.all(12),
  child: SingleChildScrollView(...)
)
```

---

## **REPORT SCREEN** (`report_screen.dart`)
**Lines: ~600** | **Purpose:** Submit disaster reports

### Trivia
- **GPS auto-fills** location
- **Type dropdown** for disaster category
- **Media upload** with preview
- Form **validation** before submission

### Teacher might ask...

**Q: "Add a new disaster type"**
- Find: Disaster types list/dropdown
- Add to list of types:
```dart
'VOLCANIC', // New type
'TSUNAMI',
'FLOOD',
```

**Q: "Make location required field"**
- Add validation to location field (if needed)
- Check before submit:
```dart
if (_locationName.isEmpty) {
  throw ApiException('Please set location');
}
```

**Q: "Add a severity/urgency field"**
- In form, add dropdown:
```dart
DropdownButton(
  items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((sev) {
    return DropdownMenuItem(value: sev, child: Text(sev));
  }).toList(),
  onChanged: (value) {
    severity = value;
  }
)
```

---

## **MY POSTS SCREEN** (`user_posts_screen.dart`)
**Lines: ~400** | **Purpose:** User's own disaster reports

### Trivia
- Shows **only logged-in user's posts** (filtered by userName)
- Can **edit** and **delete** posts
- Shows **post stats** (views, upvotes, comments)
- Refresh button **reloads user's posts**

### Teacher might ask...

**Q: "Add a view counter"**
- Each post already has stats shown
- To add: Just display it in card:
```dart
Text('Views: ${report['views'] ?? 0}')
```

**Q: "Remove delete functionality"**
- Remove this button from popup menu:
```dart
// DELETE THIS:
PopupMenuItem(
  child: Text('Delete'),
  onTap: () => _deletePost(post['id']),
),
```

**Q: "Show only PENDING posts"**
- In `_loadUserPosts()`, filter:
```dart
return reports.where((report) {
  return report['userName'] == userName 
    && report['status'] == 'PENDING'; // ADD THIS
}).toList();
```

---

## **NGO DASHBOARD** (`ngo_dashboard_screen.dart`)
**Lines: ~450** | **Purpose:** NGO operations overview

### Trivia
- Shows **real-time stats** (active reports, resources, team)
- Quick action buttons navigate to **NGO-specific screens**
- Uses **same map** as citizen but for resource planning

### Teacher might ask...

**Q: "Show top 3 recent reports instead of all"**
- Take only first 3:
```dart
final topReports = reports.take(3).toList();
```

**Q: "Add total resource count"**
- Calculate in build:
```dart
int totalResources = resources.fold(0, (sum, r) => sum + r['quantity']);
```

---

## **NGO REPORT MANAGEMENT** (`ngo_report_management_screen.dart`)
**Lines: ~700** | **Purpose:** Manage disaster reports

### Trivia
- **Filter by type, status, severity**
- Can **update status** on reports
- Can **assign resources** and **allocate budget**
- Tap report to see full **detail modal**

### Teacher might ask...

**Q: "Add a search field"**
- Add TextField:
```dart
TextField(
  onChanged: (query) {
    setState(() {
      filteredReports = reports.where((r) =>
        r['title'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
)
```

**Q: "Change the status values"**
- Find status dropdown options
- Change: `['PENDING', 'IN_PROGRESS', 'RESOLVED']`
- To: `['NEW', 'ACTIVE', 'CLOSED']`

---

## **INVENTORY MANAGEMENT** (`inventory_management_screen.dart`)
**Lines: ~600** | **Purpose:** Manage NGO resources

### Trivia
- **Add/update/delete** resources
- Track **quantities and categories**
- Show **allocation history**
- **Low stock alerts**

### Teacher might ask...

**Q: "Add expiration date tracking"**
- Add to each resource:
```dart
'expirationDate': DateTime.now().add(Duration(days: 365))
```
- Show in card:
```dart
Text('Expires: ${resource['expirationDate']}'
```

**Q: "Add low stock alert threshold"**
```dart
if (resource['quantity'] < 10) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Low stock: ${resource['name']}'))
  );
}
```

---

## **BOTTOM NAVIGATION DRAWER** (`expandable_bottom_nav.dart`)
**Lines: ~400** | **Purpose:** Main navigation hub

### Trivia
- **Swipe-up gesture** to expand
- **Role-based menu** (different for Citizen vs NGO)
- Shows **user profile** when expanded
- **Logout button** at bottom

### Teacher might ask...

**Q: "Add more secondary menu items"**
- Find: `_getSecondaryItems()` method
- Add to list:
```dart
NavItem(Icons.download, 'Downloads', 'downloads'),
```

**Q: "Change navigation menu colors"**
- Find: `Container(gradient: LinearGradient(...)`
- Change colors:
```dart
colors: [Colors.blue, Colors.purple], // New colors
```

**Q: "Make it tap-to-open instead of swipe"**
- Remove `onPanUpdate` gesture
- Add button:
```dart
FloatingActionButton(
  onPressed: _toggleExpansion,
)
```

---

## **QUICK ANSWER TEMPLATES**

### **"How does [X] work?"**
Structure: "It uses a **[StatefulWidget/StatelessWidget]**. When [something happens], it calls **[method]**, which updates the **[data]** and calls **setState()** to rebuild the UI."

Example: "The chatbot uses a StatefulWidget. When you tap a quick action, it calls `_sendQuickResponse()`, which adds the response to the `_messages` list and calls `setState()` to rebuild the UI showing the new message."

### **"Can you add [X]?"**
Structure: "Sure! Find **[file.dart]**, locate **[method/variable]**, and [action]."

Example: "Sure! Find `login_screen.dart`, locate the `_mockUsers` list, and add a new user object."

### **"Why is [X] like that?"**
Structure: "It's **[design decision]** because **[reason]**."

Example: "Upvotes are toggles because it's more intuitive - users expect tapping again to undo their action."

---

**Now you're ready to answer ANY question about the frontend! 🚀**
