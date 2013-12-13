GitHub-Time-Tracking-Hooker
===========================

Ruby Sinatra app that analyzes GitHub Comments for special emoji that indicate time spent on an issue



## Usage Patterns

### Logging Time for a Issue

1. `:clock1: 2h`

2. `:clock1: 2h | 3pm`

3. `:clock1: 2h | 3:20pm`

4. `:clock1: 2h | Feb 26, 2014`

5. `:clock1: 2h | Feb 26, 2014 3pm`

6. `:clock1: 2h | Feb 26, 2014 3:20pm`

7. `:clock1: 2h | Installed security patch and restarted the server.`

8. `:clock1: 2h | 3pm | Installed security patch and restarted the server.`

9. `:clock1: 2h | 3:20pm | Installed security patch and restarted the server.`

10. `:clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.`

11. `:clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.`

12. `:clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.`


- Dates and times can be provided in various formats, but the above formats are recommended for plain text readability.

- Any GitHub.com support clock Emoji is supported:
":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", ":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", ":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", ":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", ":clock4:", ":clock530:", ":clock7:", ":clock830:"


### Logging Budgets for a Issue

1. `:dart: 1w` # => :dart: 1w

2. `:dart: 1w | We cannot go over this time at all!` # => :dart: 1w | We cannot go over this time at all! 



## Sample Data Structure for Reporting

![screen shot 2013-12-13 at 1 38 58 am](https://f.cloud.github.com/assets/1994838/1740302/e4281c18-63c1-11e3-8674-fda74e89f628.png)


## Future Features

1. Tracking of Billable and non-billable hours
2. Breakdown by Milestones
3. Breakdown by User
4. Breakdown by Labels
5. Printable View
6. Import from CSV
7. Export to CSV
8. Budget Tracking (What is the allocated budget of a issue, milestone, label, etc)