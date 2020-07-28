# App Testdata Importer

<!--- mdtoc: toc begin -->

1.	[Synopsis](#synopsis)
2.	[Retrieve Data](#retrieve-data)<!--- mdtoc: toc end -->

## Synopsis

The App Testdata Importer is a shell script that imports csv files into postgresql databases. It creates the tables according to the headers found in the csv file. Datatypes can be configured in a `_conf.toml` that has to be in the corresponding folder.

## Retrieve Data

Let's take Applause as an example. Testdata can be retrieved via the [Query Interface](https://www.plate-archive.org/query/). Fire select statements to get the required tables.

```sql
select * from applause_dr3.archive
```
