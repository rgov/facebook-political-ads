-- Your SQL goes here
alter table ads add column author_url text;
update ads set author_url = substring(html from 'https?...www\.facebook\.com/[^\/]+/') where html is not null;