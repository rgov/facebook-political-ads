extern crate server;
extern crate diesel;
extern crate dotenv;
extern crate chrono;
extern crate rand;
extern crate r2d2;
extern crate r2d2_diesel;

use diesel::prelude::*;
use server::models::Ad;
use server::schema::ads::dsl::*;

use server::targeting_parser::parse_targeting;

mod common;

#[test]
fn test_parse_targeting() {
    let connection = common::connect();
    common::seed(&connection);

    let adverts = ads
        .filter(targeting.is_not_null())
        .filter(lang.eq("en-US"))
        .load::<Ad>(&connection)
        .unwrap();

    for ad in adverts {
        let t = ad.clone().targeting.unwrap();
        let ad_targets = parse_targeting(&t);
        if ad_targets.is_err() {
            println!("{:?}", ad.clone().targeting);
            assert!(false);
        }
    }

    common::unseed(&connection);
}

#[test]
fn getting_targets() {
    use std::collections::HashMap;
    use server::models::Targets;
    use server::models::Aggregate;

    let connection = common::connect();
    common::seed_political(&connection);

    let db_pool = common::connect_pool();
    let options: HashMap<String, String> = HashMap::new();

    let t: Vec<Targets> = Targets::get("en-US", &db_pool, &options).unwrap();
    assert!(t.iter().nth(0).is_some());

    common::unseed(&connection);
}
