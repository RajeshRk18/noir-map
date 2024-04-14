use dep::std::cmp::{Eq, Ord};
use dep::std::default::Default;

struct Item<K, V> {
    key: K,
    value: V,
    // index of the previous value. It stores the index of the item whose key is immediately lesser than the current item key
    // none if the item has the smallest key
    previous: Option<u32>,
    // index of the next value. It stores the index of the item whose key is immediately greater than the current item key
    // none if the item has the largest key
    next: Option<u32>,
}

impl<K, V> Default for Item<K, V> where K: Default, V: Default {
    fn default() -> Self {
        Self {
            key: K::default(),
            value: V::default(),
            previous: Option::none(),
            next: Option::none(),
        }
    }
}

///
/// A key sorted map using linked list
///
struct Map<K, V, N> {
    entries: [Item<K, V>; N],
    // no of entries occupied
    size: u32,
    // tracks if the map is empty
    is_empty: bool,
    // tracks the smallest and the largest entry (by keys) 
    // useful when inserting or removing the entries
    small_index: u32,
    big_index: u32,
}

impl<K, V, N> Map<K, V, N> {
    pub fn new() -> Self 
    where K: Default, V: Default {
        let entries = [Item::default(); N];
        let size = 0;
        let is_empty = true;
        let small_index = 0;
        let big_index = 0;

        Self { entries, size, is_empty, small_index, big_index }
    }

    unconstrained fn find_relative_key_location(self, key: K) -> (Option<u32>, Option<u32>, bool, bool, bool) 
    where K: Eq + Ord {
        let mut previous_index = Option::none();
        let mut next_index = Option::none();

        let mut insert_between_two_entries = false;
        let mut insert_at_start = false;
        let mut insert_at_end = false;

        for i in 0..N {
            let entry = self.entries[i];

            // CASE1: Small index
            // CASE2: Large index
            // CASE3: Insert between two entries
            // CASE4: Insert between two entries where the previous entry is first index (exception handling)
            if entry.previous.is_none() & (self.small_index == i) & (key < entry.key) & !self.is_empty {
                previous_index = Option::none();
                next_index = Option::some(i);
                insert_at_start = true;
            } 
            else if entry.next.is_none() & (self.big_index == i) & (entry.key < key) & !self.is_empty {
                next_index = Option::none();
                previous_index = Option::some(i);
                insert_at_end = true;
            } 
            else if (entry.key < key)
                & entry.previous.is_some()
                & entry.next.is_some()
                & !(self.small_index == i) {
                // safe unwrap
                if key < self.entries[entry.next.unwrap_unchecked()].key {
                    previous_index = Option::some(i);
                    next_index = Option::some(entry.next.unwrap());
                    insert_between_two_entries = true;
                }
            } 
            else if (entry.key < key)
                & entry.previous.is_none()
                & entry.next.is_some()
                & (self.small_index == i) {
                if key < self.entries[entry.next.unwrap_unchecked()].key {
                    previous_index = Option::some(i);
                    next_index = Option::some(entry.next.unwrap());
                    insert_between_two_entries = true;
                }
            }
        }

        (previous_index, next_index, insert_between_two_entries, insert_at_start, insert_at_end)
    }

    // inserts an entry in the map or updates the existing value if the key is already existing
    pub fn insert(
        &mut self,
        key: K,
        value: V
    ) -> Option<V> 
    where K: Eq + Ord + Default, V: Default {
        let (found_index, found_collision) = self.check_for_collision(key);
        let mut old_value = Option::none();

        let mut new_entry = Item::default();
        new_entry.key = key;
        new_entry.value = value;

        let (previous_index, next_index, insert_between_two_entries, insert_at_start, insert_at_end) = self.find_relative_key_location(key);

        let path_check = ((insert_between_two_entries + insert_at_end + insert_at_start) & !found_collision) as Field
            + found_collision as Field
            + self.is_empty as Field;
        assert_eq(path_check, 1);

        let index_check = (((insert_at_end & next_index.is_none())
            + (insert_at_start & previous_index.is_none())
            + (insert_between_two_entries & previous_index.is_some() & next_index.is_some()))
            & !found_collision) as Field
            + self.is_empty as Field
            + found_collision as Field;
        assert_eq(index_check, 1);

        // CASE1: if map is entry
        // CASE2: if found_collison
        // CASE3: previous_index relative to the given key is the first non-empty entry
        // CASE4: next_index relative to the given key is the last non-empty entry
        // CASE5: insert between two entries
        if self.is_empty {
            self.small_index = self.size;
            self.big_index = self.size;
        } 
        else if found_collision {
            let collided_entry = self.entries[found_index];
            let found_key = collided_entry.key;
            assert_eq(found_key, key);
            old_value = Option::some(collided_entry.value);
            self.entries[found_index].value = value;
        } 
        else if previous_index.is_none() {
            self.entries[next_index.unwrap_unchecked()].previous = Option::some(self.size);
            new_entry.next = next_index;
            self.small_index = self.size;
        } 
        else if next_index.is_none() {
            self.entries[previous_index.unwrap_unchecked()].next = Option::some(self.size);
            new_entry.previous = previous_index;
            self.big_index = self.size;
        } 
        else {
            new_entry.previous = previous_index;
            new_entry.next = next_index;
            self.entries[previous_index.unwrap_unchecked()].next = Option::some(self.size);
            self.entries[next_index.unwrap_unchecked()].previous = Option::some(self.size);
        }

        self.entries[self.size] = new_entry;
        self.size += 1 - found_collision as u32;
        self.is_empty = false;

        old_value
    }

    // Removes an entry from the map.
    // panics if the key is not in the map
    pub fn remove(&mut self, key: K) -> Option<V> 
    where K: Eq + Default, V: Default {
        let mut value = Option::none();

        let (found_index, found_collision) = self.check_for_collision(key);

        assert(found_collision);

        let found_entry = self.entries[found_index];

        // CASE1: if one entry is remaining
        // CASE2: if small_index
        // CASE3: if big_index
        // CASE4: if other
        if found_entry.next.is_none() & found_entry.previous.is_none() {
            self.entries[found_index] = Item::default();
            self.is_empty = true;
        } 
        else if found_index == self.small_index {
            let next = self.entries[self.small_index].next;
            self.entries[self.entries[self.small_index].next.unwrap()].previous = Option::none();
            self.entries[self.small_index] = Item::default();
            self.small_index = next.unwrap();
        } 
        else if found_index == self.big_index {
            let entry = self.entries[self.big_index];
            let previous = entry.previous.unwrap();
            self.entries[previous].next = Option::none();
            self.entries[self.big_index] = Item::default();
            self.big_index = previous;
        } 
        else {
            let previous_index = self.entries[found_index].previous;
            let next_index = self.entries[found_index].next;
            self.entries[previous_index.unwrap()].next = self.entries[found_index].next;
            self.entries[next_index.unwrap()].previous = self.entries[found_index].previous;
            self.entries[found_index] = Item::default();
        }

        value = Option::some(found_entry.value);
        self.size -= 1;
        self.is_empty = self.size == 0;

        value
    }

    // returns the number of entries
    pub fn len(self) -> u32 {
        self.size
    }

    // checks if the map is empty
    pub fn is_empty(self) -> bool {
        self.is_empty
    }

    // returns the index of the key
    unconstrained fn find_key_location(self, key: K) -> u32 
    where K: Eq {
        let mut found: bool = false;
        let mut index: u32 = 0;
        for i in 0..N {
            if (key == self.entries[i].key) {
                index = i;
                found = true;
                break;
            }
        }
        assert(found == true);
        index
    }

    // TODO: Should output true only if the occupied entry's key is zero  
    // currently, this will output true even if an entry is unoccupied as default item's key is also zero.
    unconstrained fn check_for_collision(self, key: K) -> (u32, bool) 
    where K: Eq {
        let mut found_index = 0;
        let mut found: bool = false;
        for i in 0..N {
            if (self.entries[i].key == key) {
                found_index = i;
                found = true;
                break;
            }
        }
        (found_index, found)
    }

    // checks whether the given key exists
    pub fn contains_key(self, key: K) -> bool 
    where K: Eq {
        let (index, contains) = self.check_for_collision(key);
        assert(self.entries[index].key == key);

        contains
    }

    // returns the value of the corresponding key
    pub fn at(self, key: K) -> V 
    where K: Eq {
        let index = self.find_key_location(key);
        assert(self.entries[index].key == key);
        self.entries[index].value
    }

    // returns the item of the corrsponding key
    pub fn get(self, key: K) -> Item<K, V> 
    where K: Eq {
        let index = self.find_key_location(key);
        assert(self.entries[index].key == key);
        self.entries[index]
    }

    // returns an array of keys in the map
    pub fn keys(self) -> BoundedVec<K, N> 
    where K: Eq + Default 
    {
        // TODO: Make this constrained
        self.get_keys()
    }

    unconstrained fn get_keys(self) -> BoundedVec<K, N>
    where K: Eq + Default 
    {
        let mut keys = BoundedVec::new();

        for i in 0..N {
            let entry = self.entries[i];
            let is_final_entry = entry.next.is_none() & entry.previous.is_none() & !self.is_empty;

            // we dont push unoccupied entry's key
            if !is_final_entry {
                continue;
            }
            keys.push(entry.key);
        }

        keys
    }

    pub fn values(self) -> BoundedVec<V, N>
    where V: Default
    {   
        // TODO: Make this constrained
        self.get_values()
    }

    unconstrained fn get_values(self) -> BoundedVec<V, N> 
    where V: Default 
    {
        let mut values = BoundedVec::new();

        for i in 0..N {
            let entry = self.entries[i];
            let is_final_entry = entry.next.is_none() & entry.previous.is_none() & !self.is_empty;

            // we dont push unoccupied entry's value
            if !is_final_entry {
                continue;
            }
            values.push(entry.value);
        }

        values        
    }

    /*pub fn clear(&mut self) {
        Map::default()
    }*/

}

impl<K, V, N> Default for Map<K, V, N> where K: Default, V: Default {
    fn default() -> Self {
        Self {
            entries: [Item::default(); N],
            size: 0,
            is_empty: true,
            small_index: 0,
            big_index: 0,
        }
    }
}
