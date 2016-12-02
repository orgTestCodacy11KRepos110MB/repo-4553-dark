import sqlite3

import dark
import fields

class DB(object):
  def __init__(self, name):
    name = name.lower()
    self.name = name
    self.conn = sqlite3.connect(":memory:", check_same_thread=False)
    self.create_table()

  def exe(self, sql, *values):
    print(sql)
    try:
      return self.conn.execute(sql)
    except BaseException as e:
      print("error: " + str(e))

  def create_table(self):
    self.exe("create table " + self.name + "(id INTEGER PRIMARY KEY AUTOINCREMENT) ")

  def add_column(self, field):
    self.exe("ALTER TABLE %s ADD %s" % (self.name, field))

  def insert(self, value):
    cols = value.keys()
    vals = [str(v) for v in value.values()]

    self.exe("insert into %s values (NULL, \"%s\")" % (self.name, "\",\"".join(vals)))


  def update(self, value, key):
    raise "TODO"
    self.exe()

  def fetch(self, num):
    return self.exe("select * from " + self.name + " limit " + str(num)).fetchall()

  def fetch_by_key(self, key, keyname):
    return self.exe("select * from " + self.name + " where " + keyname + "=" + str(key) + " limit 1").fetchone()


class Datastore(dark.Node):

  def __init__(self, name):
    self.db = DB(name) # TODO single DB for multiple DSs
    self.name = name
    self.fields = {}
    self.derived = {}


  def is_datasource(self):
    return True

  def add_field(self, f, derived=None):
    if derived:
      self.derived[f.name] = derived

    self.fields[f.name] = f
    self.db.add_column(f.name)

  def validate_key(self, key_name, value):
    self.fields[key_name].validate(value)

  def validate(self, value):
    for k, v in value.items():
      self.fields[k].validate(v)
    if len(value.items()) != len(self.fields):
      raise "either missing field declaration or missing value"

  def get_data(self, *args):
    assert(len(args) == 0)
    return self.fetch(10000)

  def get_schema(self, *args):
    return {f.name: f for f in self.fields.values()}

  def add_derived(self, value):
    for k,v in self.derived.items():
      dk1 = type(self.fields[k]).__name__
      dk2 = type(self.fields[v]).__name__
      derivation = fields.derivations[dk2][dk1]
      value[k] = derivation(value[v])
      print("Deriving %s for %s from %s" % (value[k], k, value[v]))
    return value


  def push_data(self, value):
    self.insert(value)

  def insert(self, value):
    value = self.add_derived(value)
    self.validate(value)
    self.db.insert(value)

  def replace(key, value):
    value = self.add_derived(value)
    self.validate_key(key)
    self.validate(value)
    self.db.update(key, value, self.key)

  def fetch(self, num=10):
    return self.db.fetch(num)

  def fetch_one(self, key, key_name):
    return self.db.fetch_by_key(key_name, key)
