#!/usr/bin/env bash

# Desc: tag notmuch mail

echo "Importing new mail"
notmuch new

echo "Running global tag additions to tag new mail"

# sent from me
notmuch tag +sent from:burnsac@me.com and not tag:sent
notmuch tag +sent from:lucas@burnsac.xyz and not tag:sent
notmuch tag +sent from:burnsppl@gmail.com and not tag:sent

# sent to me (all)
notmuch tag +to-me to:burnsac at me.com and not tag:to-me
notmuch tag +to-me to:lucas at burnsac.xyz and not tag:to-me
notmuch tag +to-me to:burnppl at gmail.com and not tag:to-me

notmuch tag +apple to:burnsac at me.com and not tag:apple
notmuch tag +xyz to:lucas at burnsac.xyz and not tag:xyz
notmuch tag +gmail to:burnsppl at gmail.com and not tag:gmail

notmuch tag -new -- tag:new and from:burnsac@me.com
notmuch tag -new -- tag:new and from:lucas@burnsac.xyz
notmuch tag -new -- tag:new and from:burnsppl@gmail.com

echo "Done"
