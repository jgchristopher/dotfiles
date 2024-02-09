    Insert Daily Quote Image from Readwise

# Q1

![[2024 - Quarter 1 Goals]]

# Daily Start

- [Update To Evening](shortcuts://run-shortcut?name=Update%20To%20Evening)
- [Open Today in Things](things:///show?id=today)

# Notes created or possibly updated today

```dataview
TABLE
file.folder as "Path",
file.frontmatter.tags as "Tags",
string(split(string(file.ctime), " - ")[0]) as "Created"
WHERE contains(file.path, "<% tp.date.now('YYYY-MM-DD') %>")
OR (file.cday = date("<%tp.date.now('YYYY-MM-DD')%>") AND !regexmatch("^d{4}-d{2}-d{2}", file.name))
OR file.frontmatter.peeked = "<%tp.date.now('YYYY-MM-DD')%>"
SORT file.ctime ASC
```

# Arbol

# Daily Log

# Finance
