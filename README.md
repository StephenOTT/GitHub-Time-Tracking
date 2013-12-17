GitHub-Time-Tracking
===========================

Ruby app that analyzes GitHub Issue Comments, Milestones, and Code Commit Messages for Time Tracking and Budget Tracking information.

GitHub-Time-Tracking is designed to offer maximum flexibility in the way you use GitHub to track your time and budgets, but provide a time and budget syntax that is intuitive to use and read.  Any emoji that is used was specifically chosen to be intuitive to its purpose.  Of course you can choose your own set of Emoji if you do not like the predefined ones.

**If you like GitHub-Time-Tracking, but sure to check out GitHub-Analytics: https://github.com/StephenOTT/GitHub-Analytics**


## Usage Patterns

### Logging Time for an Issue

Logging time for a specific issue should be done in its own comment.  The comment should not include any data other than the time tracking information.


#### Examples

1. `:clock1: 2h` # => :clock1: 2h

2. `:clock1: 2h | 3pm` # => :clock1: 2h | 3pm

3. `:clock1: 2h | 3:20pm` # => :clock1: 2h | 3:20pm

4. `:clock1: 2h | Feb 26, 2014` # => :clock1: 2h | Feb 26, 2014

5. `:clock1: 2h | Feb 26, 2014 3pm` # => :clock1: 2h | Feb 26, 2014 3pm

6. `:clock1: 2h | Feb 26, 2014 3:20pm` # => :clock1: 2h | Feb 26, 2014 3:20pm

7. `:clock1: 2h | Installed security patch and restarted the server.` # => :clock1: 2h | Installed security patch and restarted the server.

8. `:clock1: 2h | 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3pm | Installed security patch and restarted the server.

9. `:clock1: 2h | 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3:20pm | Installed security patch and restarted the server.

10. `:clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.

11. `:clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.

12. `:clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.


- Dates and times can be provided in various formats, but the above formats are recommended for plain text readability.

- Any GitHub.com supported `clock` Emoji is supported:
":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", ":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", ":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", ":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", ":clock4:", ":clock530:", ":clock7:", ":clock830:"

#### Sample
![screen shot 2013-12-15 at 8 41 35 pm](https://f.cloud.github.com/assets/1994838/1751599/b03deba6-65f3-11e3-9a4a-6e30ca750fd6.png)



### Logging Time for a Code Commit

When logging time in a Code Commit, the code commit message should follow the usage pattern.  The commit message that you would normally submit as part of the code commit comes after the time tracking information.  See example 7 below for a typical usage pattern.  Code Commit time logging can be done as part of the overall Git Commit Message, individual GitHub Commit Comment or Line Comment.

#### Examples

1. `:clock1: 2h` # => :clock1: 2h

2. `:clock1: 2h | 3pm` # => :clock1: 2h | 3pm

3. `:clock1: 2h | 3:20pm` # => :clock1: 2h | 3:20pm

4. `:clock1: 2h | Feb 26, 2014` # => :clock1: 2h | Feb 26, 2014

5. `:clock1: 2h | Feb 26, 2014 3pm` # => :clock1: 2h | Feb 26, 2014 3pm

6. `:clock1: 2h | Feb 26, 2014 3:20pm` # => :clock1: 2h | Feb 26, 2014 3:20pm

7. `:clock1: 2h | Installed security patch and restarted the server.` # => :clock1: 2h | Installed security patch and restarted the server.

8. `:clock1: 2h | 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3pm | Installed security patch and restarted the server.

9. `:clock1: 2h | 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3:20pm | Installed security patch and restarted the server.

10. `:clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.

11. `:clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.

12. `:clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.


- Dates and times can be provided in various formats, but the above formats are recommended for plain text readability.

- Any GitHub.com supported `clock` Emoji is supported:
":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", ":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", ":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", ":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", ":clock4:", ":clock530:", ":clock7:", ":clock830:"

#### Sample
##### Code Commit Message:
![screen shot 2013-12-15 at 8 42 55 pm](https://f.cloud.github.com/assets/1994838/1751603/ca03597c-65f3-11e3-82a8-0fa293f69d84.png)
![screen shot 2013-12-15 at 8 42 43 pm](https://f.cloud.github.com/assets/1994838/1751604/ca044274-65f3-11e3-9b60-4a912959c19b.png)

##### Code Commit Comment:
![screen shot 2013-12-16 at 10 20 22 am](https://f.cloud.github.com/assets/1994838/1757115/00735ccc-667c-11e3-8656-57caaae42e04.png)

##### Code Commit Line Comment:
![screen shot 2013-12-16 at 10 19 55 am](https://f.cloud.github.com/assets/1994838/1757116/00741680-667c-11e3-9a2f-ba9128a60515.png)


### Logging Budgets for an Issue

Logging a budget for a specific issue should be done in its own comment.  The comment should not include any data other than the budget tracking information.

#### Examples

1. `:dart: 5d` # => :dart: 5d

2. `:dart: 5d | We cannot go over this time at all!` # => :dart: 5d | We cannot go over this time at all! 

#### Sample
![screen shot 2013-12-15 at 8 46 33 pm](https://f.cloud.github.com/assets/1994838/1751609/24b45bbe-65f4-11e3-8a5e-86b0cfb12a74.png)


### Logging Budgets for a Milestone

Logging a budget for a milestone should be done at the beginning of the milestone description.  The typical milestone description information comes after the budget information.  See example 2 below for a typical usage pattern.

#### Examples

1. `:dart: 5d` # => :dart: 5d

2. `:dart: 5d | We cannot go over this time at all!` # => :dart: 5d | We cannot go over this time at all! 

#### Sample
![screen shot 2013-12-15 at 8 42 04 pm](https://f.cloud.github.com/assets/1994838/1751601/bb73ed86-65f3-11e3-9abb-4c47eabbc608.png)
![screen shot 2013-12-15 at 8 41 55 pm](https://f.cloud.github.com/assets/1994838/1751602/bb757d9a-65f3-11e3-9ac5-86dba26bc037.png)


### Tracking Non-Billable Time and Budgets

The ability to indicate where a Time Log and Budget is considered Non-Billable has been provided.  This is typically used when staff are doing work that will not be billed to the client, but you want to track their time and indicate how much non-billable/free time has been allocated.  The assumption is that all time logs and budgets are billable unless indicated to be Non-Billable.

You may indicate when a time log or budget is non-billable time in any Issue Time Log, Issue Budget, Milestone Budget, Code Commit Message, and Code Commit Comment.

To indicate if time or budgets are non-billable, you add the `:free:` :free: emoji right after your chosen `clock` emoji (like `:clock1:` :clock1:) or for budget you would place the `:free:` :free: emoji right after the `:dart:` :dart: emoji.

#### Non-Billable Time and Budget Tracking Indicator Usage Example


##### Logging Non-Billable Time for an Issue

###### Examples

1. `:clock1: :free: 2h` # => :clock1: :free: 2h


##### Logging Non-Billable Time for a Code Commit Message

###### Examples

1. `:clock1: :free:  2h` # => :clock1: :free: 2h


##### Logging Non-Billable Time for a Code Commit Comment

###### Examples

1. `:clock1: :free: 2h` # => :clock1: :free: 2h


##### Logging Non-Billable Budgets for an Issue

###### Examples

1. `:dart: :free: 5d` # => :dart: :free: 5d


##### Logging Non-Billable Budgets for a Milestone

###### Examples

1. `:dart: :free: 5d` # => :dart: :free: 5d




## Sample Data Structure for Reporting

### Time Logging in a Issue
![screen shot 2013-12-17 at 2 10 36 pm](https://f.cloud.github.com/assets/1994838/1767347/81179704-6752-11e3-8783-e3e083f5cc30.png)

### Budget Logging in a Issue
![screen shot 2013-12-17 at 2 10 58 pm](https://f.cloud.github.com/assets/1994838/1767348/8117dcc8-6752-11e3-9a69-578f11cdf21b.png)

### Budget Logging in a Milestone
![screen shot 2013-12-17 at 2 16 30 pm](https://f.cloud.github.com/assets/1994838/1767346/811700dc-6752-11e3-924f-1340642b19bf.png)

### Code Commit Time Logging - Supports Time Logging in Commit Message and Commit Comments
![screen shot 2013-12-17 at 2 17 08 pm](https://f.cloud.github.com/assets/1994838/1767349/81191ae8-6752-11e3-9a06-236006fef16c.png)

Notice the parent `Duration` field is empty.  This is due to time being logged in the commit comments rather than the the Git Commit Message.  A use case for this would be if the developer forgot to add the Time tracking information in their Git Commit Message, they can just add it to the Commit Comments after the commit has been pushed to GitHub without any issues or errors.


## Future Features

1. ~~Tracking of Billable and non-billable hours~~ Done
2. Breakdown by Milestones
3. Breakdown by User
4. Breakdown by Labels
5. Printable View
6. Import from CSV
7. Export to CSV
8. ~~Budget Tracking (What is the allocated budget of a issue, milestone, label, etc)~~ Done
9. ~~Code Commit Time Tracking~~ Done
10. Support Business Hours Time and Budget Logging. Example: 1 week will equal 5 days (1 Business Week) rather than 1 week equalling 7 days (1 Calendar Week).  Most popular use case would be able to say 1 Day would equal 8 hours rather than 24 hours.


## Process Overview

![github time tracking process overview](https://f.cloud.github.com/assets/1994838/1757137/409bf8e0-667c-11e3-9576-14400457c2c1.png)


## Data Analysis

This section will grow as the data analysis / UI is developed for the application


### Data output from Data Analyzer and MongoDB

Using the MongoDB Aggregation Framework a series of high level aggregations are preformed to provide the required data for the front-end to display needed Time Tracking information.

#### Issue Time Output

```
[
    {
        "repo_name"=>"StephenOTT/Test1", 
        "type"=>"Issue Time", 
        "assigned_milestone_number"=>1, 
        "issue_number"=>6, 
        "issue_state"=>"open", 
        "duration_sum"=>43200, 
        "issue_count"=>3
    }, 
    {
        "repo_name"=>"StephenOTT/Test1", 
        "type"=>"Issue Time", 
        "assigned_milestone_number"=>1, 
        "issue_number"=>7, 
        "issue_state"=>"open", 
        "duration_sum"=>14400, 
        "issue_count"=>1
    }
]
```

#### Issue Budget Output

```
[
    {
        "repo_name"=>"StephenOTT/Test1", 
        "type"=>"Issue Budget", 
        "issue_number"=>7, 
        "assigned_milestone_number"=>1, 
        "issue_state"=>"open", 
        "duration_sum"=>57600, 
        "issue_count"=>1
    }
]
```

#### Milestone Budget Output

```
[
    {
        "repo_name"=>"StephenOTT/Test1", 
        "type"=>"Milestone Budget", 
        "milestone_number"=>1, 
        "milestone_state"=>"open", 
        "duration_sum"=>604800, 
        "milestone_count"=>1
    }
]
```
