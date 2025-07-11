# README

## Development

### Background jobs
We use ActiveJob for executing background jobs.
Use `bin/jobs start` to run in development.

### Mail Sending
[Mailpit](https://github.com/axllent/mailpit) is available to preview mails sent in the development environment.
Simply open http://localhost:8025/ to preview sent mails.
Please be aware that e-mails are sent using background jobs, so you need to run ActiveJob as described above to trigger
the sending of mails in development.
