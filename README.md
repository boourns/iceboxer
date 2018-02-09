ICEBOXER

_over 5000 served_

![picture of the iceboxer](https://cloud.githubusercontent.com/assets/699550/5100358/75aa3366-6f73-11e4-852d-ad3205f79e3f.png)

ICEBOXER systemizes a hard decision - when is a valid issue not important enough to be fixed?

To be productive, we must default to no.  Issues should be considered irrelevant until they've been brought up many times.  Open issue count in aggregate should not affect prioritization when the open issues themselves are of little impact.

So lets close some issues.

ICEBOXER:

ICEBOXER finds:
- issues older than a year, with no updates in last 2 months
- issues not touched in the last 6 months

To those issues, ICEBOXER:
- runs a Facebook GitHub Bot "icebox" command
- the bot will in turn comment with an icebox message
- then add the Icebox label
- and close the issue.

TEMPLATENAGGER:

TEMPLATENAGGER finds issues that did not fill out the issue template.

To those issues, TEMPLATENAGGER:
- runs a Facebook GitHub Bot "no-template" command
- the bot will in turn comment with a no-template message
- then add the missing template label
- and close the issue.
