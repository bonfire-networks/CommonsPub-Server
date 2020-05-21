echo "This script helps merge upstream updates while preserving local customisations"
echo "WARNING: you must have git version 2.23 or more recent"

echo "...Checking out our MoodleNet branch"
git checkout flavour/moodlenet

echo "...Pulling changes from upstream"
git pull https://gitlab.com/moodlenet/backend.git develop 

echo "...Copying upstream changes to our MoodleNet branch"
git push

echo "...Checking out flavour/commonspub branch"
git checkout flavour/commonspub

echo "...Merging MoodleNet to CommonsPub, without commiting yet" 
git merge --no-ff --no-commit --strategy-option theirs flavour/moodlenet

echo "...Restoring files which we don't want overwritten (add any core files that should be different in CommonsPub to the below line in the script)"
for file in cpub-merge-from-upstream.sh cpub-merge-from-branch.sh README.md DEPLOY.md HACKING.md config/docker.env config/docker.dev.env Makefile docker-compose.yml docker-compose.pi.yml .gitlab-ci.yml priv/repo/migrations/20200316102402_locales.exs priv/repo/migrations/20200317103503_taxonomy.exs priv/repo/migrations/20200415105739_units_measure.exs priv/repo/migrations/20200419000000_units_pointer.exs priv/repo/migrations/20200419000001_geolocation_pointer.exs priv/repo/migrations/20200410000000_units.exs priv/repo/migrations/20200328000000_geolocation.exs
do
    git reset HEAD ${file}
    git checkout -- ${file}
done

echo "...Restoring our extension modules..."
for extension in geolocation locales measurement organisation taxonomy value_flows 
do

    echo "...Restoring ${extension}..."

    git restore --source=HEAD --staged --worktree -- lib/${extension}
    
    git restore --source=HEAD --staged --worktree -- test/${extension}

    git restore --source=HEAD --staged --worktree -- test/support/${extension}
done


echo "Please check if everything looks good (including resolving any merge conflicts) before continuing. Press 'c' to merge and push the changes, or just enter to abort."
read answer
if echo "$answer" | grep -iq "^c" ; then
    echo "Merging and pushing..."
    git commit -m "merged from upstream"
    git push
else 
    echo "Aborting the merge."
    git merge --abort
    exit 1
fi