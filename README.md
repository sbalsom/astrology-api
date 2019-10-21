# The Astrology API

This rails application scrapes several publications across the web that have a weekly, daily, or monthly horoscopes section, and compiles the results in a  in a public-facing API. The API is accessible to anyone with the url, and allows users to search for and sort horoscopes by publication, date, author name, keywords, sign, and mood. The content is truncated for copyright reasons, so users and developers are encouraged to visit the original link to see the full content of the matching horoscope.

## A note about this project

My intention is to both catalogue these horoscopes in an organized fashion, as well as provide a record for authors of the number of horoscopes they have written. A simple sentiment analysis algorithm is applied to each horoscope using the [sentiment_lib](https://github.com/nzaillian/sentiment_lib) gem by @nzaillian. This algorithm gives each horoscope a score from -20 to 20, and a corresponding mood keyword is then accorded to the horoscope instance. 

Eventually, I hope to add further complexity to the sentiment analysis, possible adding methods and operations to compare the writing styles and predictions given by each author, and take into account the emotional connotations of words specific to astrology, like "square", "trine", "eclipse", and so on. 

My original database was built around full-content horoscopes, but for copyright reasons, I eventually decided to truncate the content and add word count and mood attributes instead. What we call horoscope "content" in the database is actually the original horoscope content truncated to 100 characters, appended by the author name, word count, and original link.

Please contact me at sbalsom@protonmail.com with any questions, comments, suggestions for improvement, and bugs. If any author or publication is interested in having their full-content horoscopes indexed for internal use, or for any other collaborative project, they are welcome to contact me as well.

# How to use the API

The base url of the API, where this documentation can be found, is "
```
http://www.horoscope-api.site
```

all paths should be appended to this base url.

Horoscopes, publications, and authors are indexed at their respective endpoints :

```
/api/v1/horoscopes
```

```
/api/v1/authors 
```

``` 
/api/v1/publications
```

Accessing any of these endpoints will return a paginated index, with 25 items per page. In other words `/api/v1/horoscopes` is the same as `/api/v1/horoscopes?page=1`. Both will return the most recent 25 horoscopes that were added to the database. To access the next 25, simply change the page number.

Each model (author, publication, and horoscope) also responds to several queries, indexed in the tables below.

For publications :

| query | example values | explanation |
|:--|:--|:--|
| name | Vice, Mask Magazine, Teen%20Vogue | Searches by publication name. The name must be entered without quotation marks and must match the publication name exactly. Using %20 to replace a space is optional. The publications used in the database are : Vice, Allure, Elle, Cosmopolitan, Mask Magazine, The Cut, Teen Vogue, and Autostraddle. |

For authors :

| query | example values | explanation |
|:--|:--|:--|
| full_name | Corina, ra, Annabel%20Gat | Searches by author name, including first and last name. The name must be entered without quotation marks, and doesn't have to match the author name exactly. Using %20 to replace a space is optional. |
|min_count| 30, 1000, 1| Each author is given a horoscope_count, and the value of min_count returns only authors whose horoscope_count is above the given value.  (Returns authors who have written exactly X or more than X horoscopes) |

For horoscopes :

| query | example values | explanation |
|:--|:--|:--|
| sign | Taurus, capricorn | Searches horoscopes by sign. The sign must be entered without quotation marks, has to match the sign name exactly, but the query is case-insensitive. |
|range| 1, 7, 30 | Horoscopes are categorized as "Daily" (range = 1), "Weekly" (range = 7), or "Monthly" (range = 30)|
|beg_date, end_date | 11-01-2019, 23-09-2018 | Returns horoscopes published* between the given dates. Formats must be given as day-month-year or year-month-day. |
|min_words | 300, 30 | Returns horoscopes where the original content was above a given minimum word count. (Horoscope content is always truncated to 100 characters in the results) |
|mood | Turbulent, diff, Life%20Affirming | Horoscopes are analyzed using a sentiment analysis gem, and given a score and mood keyword. The "moods" for horoscopes are : Turbulent, Difficult, Trying, Worrisome, Neutral, Reassuring, Promising, and Life-affirming. The mood keyword in the query does not have to match the horoscope mood keyword exactly. |
|publication | cosmopolitan, Vice, Mask%20Magazine | Returns horoscopes by publication. The publication name must be exact but is case insensitive (i.e. "Cosmo" will return nothing but "cosmopolitan" works). |

** Usually "start_date" corresponds to date published, i.e. when the horoscope for the week of November 1st - 8th is published on November 1st. Depending on the practice of the publication, some horoscopes might have been originally published on a day proceeding the "start_date", as in the case of Vice dailies, which are actually published the night before the horoscope "begins". The API currently does not save publishing dates, only start_date (the day on which the horoscope becomes applicable). If any users of the API want to know the exact original publishing date, they should return to the original article and access it in the metadata of that page.

An example  of a full search query might be :

```
http://www.horoscope-api.site/api/v1/horoscopes?page=3&publication=Teen%20Vogue&beg_date=2018-04-01&end_date=10-05-2018
```

This would return the third page of horoscopes from Teen Vogue published between April 1 2018 and May 10 2018.

## Accessing individual records

A single instance of an author, publication, or horoscope can be viewed by adding its id to the path:

```
/api/v1/horoscopes/:id
```

```
/api/v1/authors/:id
```

```
/api/v1/horoscopes/:id
```

``` 
/api/v1/publications/:id
```

The id is found within the record of the given instance :

```
author": {
"id": 118,
"full_name": "Annabel Gat",
"created_at": "2019-10-05T11:35:30.933Z",
"updated_at": "2019-10-05T12:02:42.643Z",
...
}
```

"created_at" and "updated_at" describe when the record was added to the database, and when the record was last updated. They should not be confused with other attributes like "start_date" for horoscope.
