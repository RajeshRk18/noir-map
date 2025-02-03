pub mod map;
use crate::map::Map;

#[test]
fn test_insert() {
    let mut test_list: Map<u32, Field, 10> = Map::default();
    let mut value = test_list.insert(123, 456);
    assert(value.is_none());
    assert(test_list.size() == 1);
    let mut result = test_list.get(123);
    assert(result == 456);
    value = test_list.insert(128, 999);
    assert(value.is_none());
    assert(test_list.size() == 2);
    result = test_list.get(128);
    assert(result == 999);
    let first = test_list.at(123);
    let second = test_list.at(128);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    assert(first.next.unwrap() == 1);
    assert(second.previous.unwrap() == 0);
    assert(first.previous.is_none());
    assert(second.next.is_none());
    value = test_list.insert(127, 333);
    assert(value.is_none());
    let first = test_list.at(127);
    let second = test_list.at(128);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    assert(test_list.size() == 3);
    result = test_list.get(127);
    assert(result == 333);
    value = test_list.insert(123, 457);
    assert(value.is_some());
    assert(test_list.size() == 3);
    result = test_list.get(123);
    assert(result == 457);
    value = test_list.insert(1, 3);
    assert(value.is_none());
    assert(test_list.size() == 4);
    result = test_list.get(1);
    assert(result == 3);
    value = test_list.insert(69, 567);
    assert(value.is_none());
    value = test_list.insert(420, 69);
    assert(value.is_none());
    assert(test_list.size() == 6);
    result = test_list.get(69);
    assert(result == 567);
    result = test_list.get(420);
    let old_val = test_list.insert(69, 555);
    assert(old_val.is_some());
    assert(old_val.unwrap() == 567);
    let old_val = test_list.insert(420, 79);
    assert(old_val.unwrap() == 69);
}

#[test]
fn test_remove() {
    let mut test_list: Map<u32, Field, 15> = Map::default();
    let _ = test_list.insert(10, 3);
    let _ = test_list.insert(126, 333);
    let _ = test_list.insert(128, 999);
    let _ = test_list.insert(7, 1);
    // Test removing non-exisitng entry
    assert(test_list.remove(77).is_none());
    let first = test_list.at(7);
    let second = test_list.at(10);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    let mut value = test_list.remove(128);
    assert(value.is_some());
    assert_eq(value.unwrap(), 999);
    assert_eq(test_list.size(), 3);

    value = test_list.remove(7);
    assert(value.is_some());
    assert_eq(test_list.size(), 2);
    value = test_list.remove(10);
    assert(value.is_some());
    assert_eq(test_list.size(), 1);
    value = test_list.remove(126);
    assert(value.is_some());
    assert_eq(test_list.size(), 0);

    // Test removing from empty list
    assert(test_list.remove(34).is_none());
}

#[test]
fn test_get() {
    let mut map: Map<u32, u32, 10> = Map::new();
    let _ = map.insert(10, 100);
    
    assert(map.get(10) == 100);
    //assert(map.get(5)none);
}

#[test]
fn test_pop() {
    let mut map: Map<u32, u32, 10> = Map::new();
    let _ = map.insert(4, 40);
    let _ = map.insert(6, 60);
    
    let popped_value = map.pop_front();
    assert(popped_value.is_some() & (popped_value.unwrap() == (4, 40)));
    assert(map.len() == 1);
    
    let popped_value = map.pop_back();
    assert(popped_value.is_some() & (popped_value.unwrap() == (6, 60)));
    assert(map.is_empty());
}

#[test(should_fail)]
fn test_excess_capacity_fails() {
    let mut map: Map<u32, u32, 3> = Map::new();
    let _ = map.insert(1, 10);
    let _ = map.insert(2, 20);
    let _ = map.insert(3, 30);
    
    assert(map.len() == 3);
    assert(map.insert(4, 40).is_none()); // Should handle exceeding capacity properly
}
