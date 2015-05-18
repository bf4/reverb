1. please send me 5 questions about Reverb..business/technical/culture, whatever you want. make them count
2. check out our coding challenge https://reverb.com/page/dev-challenge

## Reverb Technical Challenge

Welcome! This challenge is designed to be completed on your own time.
You may use any resources you need to complete it,
including emailing questions to me at yan AT reverb DOT com.
However, please be sure that you've googled and read docs thoroughly prior to asking questions.

Rules and Guidelines

- Make a github repository and commit in small cohesive chunks.
- You can use external gems if you like, but keep in mind that by definition external dependencies add complexity, so think carefully on whether you need them.
- Do not use Rails - it is a complex external dependency that makes code review and refactoring difficult.
- You will be judged on the readability and cleanliness of your code
- Provide unit tests (RSpec or MiniTest or whatever you’re comfortable with).
  The cleanliness and readability of tests is just as important as your production code.
  Use [BetterSpecs.org](https://betterspecs.org/) as a guideline.
- Think simple. Readability and modularity are better than being clever.
- You must provide 100% test coverage for your code. Write tests first to ensure full coverage.

### Step 1 - Build a system to parse and sort a set of records

Create a command line app that takes as input a file with a set of records in one of three formats described below, and outputs (to the screen) the set of records sorted in one of three ways.

#### Input

A record consists of the following 5 fields: last name, first name, gender, date of birth and favorite color.
The input is 3 files, each containing records stored in a different format.
You may generate these files yourself, and you can make certain assumptions if it makes solving your problem easier.

- The pipe-delimited file lists each record as follows:<br>
  `LastName | FirstName | Gender | FavoriteColor | DateOfBirth`
- The comma-delimited file looks like this:<br>
  `LastName, FirstName, Gender, FavoriteColor, DateOfBirth`
- The space-delimited file looks like this:<br>
  `LastName FirstName Gender FavoriteColor DateOfBirth`

You may assume that the delimiters (commas, pipes and spaces) do not appear anywhere in the data values themselves.
Write a Ruby program to read in records from these files and combine them into a single set of records.

#### Output

Create and display 3 different views of the data you read in:

- Output 1 – sorted by gender (females before males) then by last name ascending.
- Output 2 – sorted by birth date, ascending.
- Output 3 – sorted by last name, descending.

Display dates in the format `M/D/YYYY`.

### Step 2 - Build a Grape API to access your system

Tests for this section are required as well.

Your assignment is to build a standalone [Grape API](https://github.com/intridea/grape) with the following endpoints:

- `POST /records` - Post a single data line in any of the 3 formats supported by your existing code
- `GET /records/gender` - returns records sorted by gender
- `GET /records/birthdate` - returns records sorted by birthdate
- `GET /records/name` - returns records sorted by name

It's your choice how you render the output from these endpoints as long as it well structured data. These endpoints should return JSON.

We expect that you do not yet have exposure to Grape. Part of this exercise will be the ability to read the docs and learn it quickly.

### Step 3 - Review and Refactor

When you are invited to interview in person at Reverb, we will sit down with you and offer feedback and guidance in refactoring your code. We would like to see you pick up these skills quickly and apply them during the interview to improve the structure of your solution.

Good Luck!
