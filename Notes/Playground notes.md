## Playground project

After review the technical challenge definition and gather more information from the documentation. I started to draw simple mockups for the app and write some notes. Later, I realised the available time to work and to avoid more delays, I decided to follow the approach of build, test and fail fast. So, the ideal way to go, was develope using the playground.

### New project defition

Based on the described above, this is the features list:

- 30 items to show on the list.
- Default sort by title (movie name)
- Simple data parsing, no mapper libray.
- Master-detail approach.
- Display the location on the map (MapKit).

### Pros
- Less development time required.
- Only native frameworks to be used.

### Cons
- Limited numbers of items to be displayed.
- No sorting option available.

At the end, I tried to bring a solution that could fit between the basic requirements and at least one on the plus list.

_Note: Just for fun, I included something particular to be displayed on the map when a movie doesn't have a location or there's a error with it._ 
