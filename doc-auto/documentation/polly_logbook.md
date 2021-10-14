# logbook

The polly logbook file was created with using the java scripts. Detailed information about the scripts can be found [here][1].

## Format

```
"id";"time";"operator";"changes";"ndfilters";"comment"
81;"20190215-1854";["mr"];[];{5 3.8, 6 2};"adjusted ND filters for DFOV test 532FR 3.3 -> 3.8 532cFR 1.8->2.0"
```

|Variable|Description|Type|Example|
|:------:|:----------|:--:|:-----:|
|   id   |log number |integer|  81   |
|   time |time for adding the log, with format of `YYYYMMDD-HHMM`|string|20190215-1854|
| operator|who did the operation|string|mr|
|changes|what was changed|string|"overlap" "windowwipe" "flashlamps" and "pulsepower" and "restarted"|
|ndfilters| detailed information about channel filter changes. {channel_number OD}|compound|{5 3.8}|
|comment| additional information for the changes|string|adjusted ND filters for DFOV test 532FR 3.3 -> 3.8 532cFR 1.8->2.0|

[1]: https://gitea.tropos.de/radenz/pollylog