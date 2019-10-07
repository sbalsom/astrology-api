# The Astrology API

This rails application scrapes several publications across the web that have a weekly, daily, or monthly horoscopes section, and compiles the results in a  in a public-facing API (not currently live). Once deployed, the API will be accessible to anyone with the url, and will allow users to search for and sort horoscopes by publication, date, author name, keywords, sign, and mood. The content is truncated for copyright reasons, so users and devleopers are encouraged to visit the original link to see the full content of the matching horoscope.

## A note about this project

My intention is to both catalogue these horoscopes in an organized fashion, as well as provide a record for authors of the number of horoscopes they have written. A simple sentiment analysis algorithm is applied to each horoscope using the [sentiment_lib](https://github.com/nzaillian/sentiment_lib) gem by @nzaillian. This algorithm gives each horoscope a score from -20 to 20, and a corresponding mood keyword is then accorded to the horoscope instance. 

Eventually, I hope to add further complexity to the sentiment analysis, possible adding methods and operations to compare the writing styles and predictions given by each author, and take into account the emotional connotations of words specific to astrology, like "square", "trine", "eclipse", and so on. 

My original database was built around full-content horoscopes, but for copyright reasons, I eventually decided to truncate the content and add word count and mood attributes instead.

Please contact me at sbalsom@protonmail.com with any questions, comments, suggestions for improvement. If any author or publication is interested in having their full-content horoscopes indexed for internal use, or for any other collaborative project, they are welcome to contact me as well.

# How to use the API

Horoscopes, publications, and authors are indexed at their respective endpoints :

```/api/v1/horoscopes
```

```  /api/v1/authors/ 
```

``` /api/v1/publications/
```

And a single instance of an author, pulication, or horoscope can be viewed by its id :

```/api/v1/horoscopes/:id
```

```  /api/v1/authors/:id 
```

``` /api/v1/horoscopes/:id
```

``` /api/v1/publications/:id
```



