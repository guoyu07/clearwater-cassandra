#!/bin/bash

# @file list_backups.sh
#
# Project Clearwater - IMS in the Cloud
# Copyright (C) 2013  Metaswitch Networks Ltd
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version, along with the "Special Exception" for use of
# the program along with SSL, set forth below. This program is distributed
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details. You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
# The author can be reached by email at clearwater@metaswitch.com or by
# post at Metaswitch Networks Ltd, 100 Church St, Enfield EN2 6BQ, UK
#
# Special Exception
# Metaswitch Networks Ltd  grants you permission to copy, modify,
# propagate, and distribute a work formed by combining OpenSSL with The
# Software, or a work derivative of such a combination, even if such
# copying, modification, propagation, or distribution would otherwise
# violate the terms of the GPL. You must comply with the GPL in all
# respects for all of the code used other than OpenSSL.
# "OpenSSL" means OpenSSL toolkit software distributed by the OpenSSL
# Project and licensed under the OpenSSL Licenses, or a work based on such
# software and licensed under the OpenSSL Licenses.
# "OpenSSL Licenses" means the OpenSSL License and Original SSLeay License
# under which the OpenSSL Project distributes the OpenSSL toolkit software,
# as those licenses appear in the file LICENSE-OPENSSL.

finish () {
  rc=${2-2}
  echo >&2 "$1"
  exit $rc
}

[ "$#" -ge 1 ] || finish "Usage: list_backup.sh <keyspace> [backup directory]" 1
KEYSPACE=$1
COMPONENT=$(cut -d_ -f1 <<< $KEYSPACE)
DATABASE=$(cut -d_ -f2 <<< $KEYSPACE)
BACKUP_DIR=$2
DATA_DIR=/var/lib/cassandra/data
[ -d "$DATA_DIR/$KEYSPACE" ] || finish "Keyspace $KEYSPACE does not exist" 1

if [[ -z "$BACKUP_DIR" ]]
then
  if [ -n "$DATABASE" ]
  then
    BACKUP_DIR="/usr/share/clearwater/$COMPONENT/backup/backups/$DATABASE"
  else
    BACKUP_DIR="/usr/share/clearwater/$COMPONENT/backup/backups"
  fi
  echo "No backup directory specified, defaulting to $BACKUP_DIR"
else
  echo "Will look for backups in $BACKUP_DIR"
fi

if [[ "$(ls -A $BACKUP_DIR)" ]]
then
  for b in $BACKUP_DIR/*
  do
    SNAPSHOT=`basename $b`
    echo "$SNAPSHOT"
  done
else
  finish "No backups exist in $BACKUP_DIR" 0
fi
