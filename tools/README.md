# Tools directory
This directory is intended to gather all Linux-based applications.

To add a new tool, just add a directory in `tools` with the name of the tool and put necessary source files and Makefile in it. Also do not forget to add the name of the tool in this path.

```
tools/
|
+-- Makefile/
|	    |TOOLS += \
|	    |    <tool-name>
|	 	`----
```

Good luck!
