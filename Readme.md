# marathon-dns

A standalone component extracted from [marathon](https://github.com/davewasmer/marathon) for enabling custom DNS for local servers. 

# Installation

_Note: requires >= Mac OS X 10.6_

    npm install marathon -g

Once it finishes, open up your project file (`~/.marathon`), and add any projects you'd like. For example, the following project file:

    {
      "myawesomeapp": 3000 
    }

would setup `http://myawesomeapp.dev` to point to `http://localhost:3000`

In addition, \*.vm[1-3] is mapped to 10.0.0.[2-4] to simplify Vagrant private network handling

That's basically it.
