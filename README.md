# RaceDay – Part 1

RaceDay is a planned full-stack web-based event management system for South African road running, walking and cycling events.

## Part 1 contents

The `/docs` folder contains:

- `RaceDay_ERD.png` – Entity Relationship Diagram.
- `API_Endpoint_Plan.md` – complete API endpoint plan.
- `RaceDayDB.sql` – SQL Server database creation and seed script.

The planning model uses five entities:

1. **Users** – stores both Organisers and Participants.
2. **Events** – stores event information and the Organiser who owns each event.
3. **Categories** – stores age/distance categories belonging to an event.
4. **Enrolments** – connects Participants to Events and their selected Categories.
5. **Results** – stores finish time and finishing position for an enrolment.

## Roles

### Organiser
- Create, edit and delete their events.
- Manage categories.
- View event enrolments.
- Capture and manage participant results.

### Participant
- Create an account and log in.
- Browse events.
- View event categories.
- Enter events and select a category.
- View personal enrolments and results.
- View/update their own profile.

## SQL setup

1. Open SQL Server Management Studio (SSMS).
2. Open `docs/RaceDayDB.sql`.
3. Execute the script on a test SQL Server instance.
4. The script creates `RaceDayDB`, creates all tables, constraints and indexes, then inserts sample data.
5. Confirm the final SELECT statements return the seeded records.

**Important:** the seed password hashes are placeholders for Part 1. Part 2 must hash real passwords before storing them.

## Part 2 implementation rule

Part 2 should be implemented against this plan. Any endpoint, field or relationship changed later should be documented clearly so the implemented API remains consistent with the approved Part 1 design.

## CI/CD

The `https://github.com/Tjikana23-MK/part1-validation.yml` workflow checks that the required Part 1 files exist in the repository.

Before submission, run the workflow through GitHub Actions and place a screenshot of the successful green build in this README.

## Video

Add the unlisted YouTube presentation link here after recording:

`couldnt access my virtual machine to create the video`

The Part 1 video should explain:
- the purpose of RaceDay;
- the ERD entities, keys and relationships;
- the API endpoint plan;
- important database constraints and seed data;
- the SQL script being executed in SSMS.

## AI-use disclosure

The POE instructs students to disclose AI use if AI tools were used for planning, proofreading or coding. If you use this material, review, understand and adapt it yourself and add the disclosure required by your institution.

## Reference

Microsoft (2026) *CREATE TABLE (Transact-SQL)*. Microsoft Learn. Available through Microsoft Learn. Accessed 2 September 2026.
