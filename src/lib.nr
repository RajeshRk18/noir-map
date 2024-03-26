mod map;
use crate::map::Map;

#[test]
fn test_insert() {
    let mut test_list: Map<u32, Field, 10> = Map::default();
    test_list.insert(123, 456);
    assert(test_list.size == 1);
    let mut result = test_list.at(123);
    assert(result == 456);
    test_list.insert(128, 999);
    assert(test_list.size == 2);
    result = test_list.at(128);
    assert(result == 999);
    let first = test_list.get(123);
    let second = test_list.get(128);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    assert(first.next.unwrap() == 1);
    assert(second.previous.unwrap() == 0);
    assert(first.previous.is_none());
    assert(second.next.is_none());
    test_list.insert(127, 333);
    let first = test_list.get(127);
    let second = test_list.get(128);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    assert(test_list.size == 3);
    result = test_list.at(127);
    assert(result == 333);
    test_list.insert(123, 457);
    assert(test_list.size == 3);
    result = test_list.at(123);
    assert(result == 457);
    test_list.insert(1, 3);
    assert(test_list.size == 4);
    result = test_list.at(1);
    assert(result == 3);
    test_list.insert(69, 567);
    test_list.insert(420, 69);
    assert(test_list.size == 6);
    result = test_list.at(69);
    assert(result == 567);
    result = test_list.at(420);
    let old_val = test_list.insert(69, 555);
    assert(old_val.unwrap() == 567);
    let old_val = test_list.insert(420, 79);
    assert(old_val.unwrap() == 69);
}

#[test]
fn test_remove() {
    let mut test_list: Map<u32, Field, 15> = Map::default();
    test_list.insert(10, 3);
    test_list.insert(126, 333);
    test_list.insert(128, 999);
    test_list.insert(7, 1);
    let first = test_list.get(7);
    let second = test_list.get(10);
    assert(test_list.entries[first.next.unwrap()].key == second.key);
    assert(test_list.entries[second.previous.unwrap()].key == first.key);
    test_list.print();
    let removed = test_list.remove(128);
    println(test_list.get(126));
    assert_eq(removed.unwrap(), 999);
    assert_eq(test_list.size, 3);
    test_list.insert(1, 45);
    let val = test_list.at(1);
    assert_eq(val, 45);
    assert_eq(test_list.size, 4);
    test_list.remove(7);
    test_list.remove(10);

    assert_eq(test_list.size, 2);
}
