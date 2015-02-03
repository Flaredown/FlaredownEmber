import resolver from './helpers/resolver';
import {
  setResolver
} from 'ember-qunit';

QUnit.config.reorder = false;

setResolver(resolver);
